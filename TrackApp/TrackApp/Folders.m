//
//  Folders.m
//  TrackApp
//
//  Created by Veatch, James E on 5/8/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "Folders.h"

@implementation Folders

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:@"folder.png"];
    [self.folderImage setImage:img];
    
    self.folderNames = [[NSMutableArray alloc] init];
    
    [DatabaseAccessors initializeDatabase];
    self.folderNames = [DatabaseAccessors loadNamesFromDatabase];
    [self insertAddRowIntoArray];
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    setupButton = [[UIBarButtonItem alloc] initWithTitle:@"Setup" style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(setupAlert)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.folderNames count];
}

//CALL THIS METHOD WHENEVER CHANGING THE SIZE OF THE TABLE
- (void) insertAddRowIntoArray
{
    [self.folderNames addObject:@""];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"folderTableCell";
    
    FolderTableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FolderTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.folderName.text = [self.folderNames
                            objectAtIndex: [indexPath row]];
    [cell.folderName setHidden:FALSE];
    [cell.folderImage setHidden:FALSE];
    
    if([indexPath row] == self.folderNames.count - 1){
        [cell.folderName setHidden:TRUE];
        [cell.folderImage setHidden:TRUE];
    }
    
    UILongPressGestureRecognizer *incremenLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(emailFolder:)];
    incremenLongPress.minimumPressDuration=1.0;
    [cell addGestureRecognizer:incremenLongPress];
    
    return cell;
}

- (void) emailFolder:(UILongPressGestureRecognizer*)sender
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:@"Progress Attached"];
        [mailCont setMessageBody:[NSString stringWithFormat:@"Attached is the %@ folder",
                                  [_folderNames objectAtIndex:[[self.tableView indexPathForSelectedRow] row]]] isHTML:NO];
        FileIoAppDelegate *temp=[FileIoAppDelegate constructWithFolderName:
                                 [_folderNames objectAtIndex:[[self.tableView indexPathForSelectedRow] row]]];
        [mailCont addAttachmentData:[NSData dataWithContentsOfFile:[temp writeFolderToFile]] mimeType:@"text//csv" fileName:@"report.csv"];
         [self presentModalViewController:mailCont animated:YES];
    }
         }
         
         
         
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    [self dismissModalViewControllerAnimated:YES];
}

    


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.folderNames.count - 1){
        return UITableViewCellEditingStyleInsert;
    }
    else{
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [DatabaseAccessors deleteFolder:[self.folderNames objectAtIndex:indexPath.row]];
        [self.folderNames removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Folder" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
        folderNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        [folderNameTextField setBackgroundColor:[UIColor whiteColor]];
        [alert addSubview:folderNameTextField];
        alert.tag = TAG_NEWFOLDER;
        [alert show];
        [folderNameTextField becomeFirstResponder];
    }
}

- (NSIndexPath*) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == self.folderNames.count - 1)
        return nil;
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == self.folderNames.count - 1)
        return NO;
    
    return YES;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if(destinationIndexPath.row >= self.folderNames.count - 1){
        [self.tableView reloadData];
        return;
    }
    NSString* stringToMove = [self.folderNames objectAtIndex:sourceIndexPath.row];
    [self.folderNames removeObjectAtIndex:sourceIndexPath.row];
    
    [self.folderNames insertObject:stringToMove atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
    //Save array of new order to database
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:FALSE];
    
}

- (IBAction)setupAlert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Main Menu" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Settings", @"Help", @"About", nil];
    alert.tag = TAG_SETUP;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == TAG_NEWFOLDER){
        if (buttonIndex != [alertView cancelButtonIndex]) {
            NSString *folderName = folderNameTextField.text;
            if (folderName != NULL && ![self.folderNames containsObject:folderName])
            {
                [self.folderNames removeLastObject];
                [self.folderNames addObject:folderName];
                [self insertAddRowIntoArray];
                [DatabaseAccessors saveNameInDatabase:folderName];
                [self.tableView reloadData];
            } else
            {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Folders must have a unique name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [errorAlert show];
            }
        }
    }
    else if(alertView.tag == TAG_SETUP){
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"About"]){
            UIAlertView *aboutAlert = [[UIAlertView alloc] initWithTitle:@"About" message:@"This is a productivity tracking application currently in development by students at Rose-Hulman Institute of Technology." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [aboutAlert show];
        }
        else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Settings"]){
            UIAlertView *settingsAlert = [[UIAlertView alloc] initWithTitle:@"Settings" message:@"There are currently no settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [settingsAlert show];
        }
        else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Help"]){
            //UIAlertView *helpAlert = [[UIAlertView alloc] initWithTitle:@"Help" message:@"This is the folder screen.  Its used to organize your tasks.  Touch a folder to see its tasks.  To add, reorder, or delete your folders or tasks, press the edit button on the top right of either screen." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            //[helpAlert show];
            
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            HelpDocController* vc = [sb instantiateViewControllerWithIdentifier:@"HelpDocController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
