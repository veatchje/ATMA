//
//  FolderTableViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH'S CODE START

#import "FolderTableViewController.h"
#import "FolderTableViewCell.h"
#import "TaskTableViewController.h"
#import "HelpDocController.h"

#define TAG_SETUP 1
#define TAG_NEWFOLDER 2

@implementation FolderTableViewController
@synthesize folderImage = _folderImage;
@synthesize folderNames = _folderNames;

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
                [self->dbAccess saveNameInDatabase:folderName];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showFolderTitle"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TaskTableViewController *destViewController = segue.destinationViewController;
        destViewController.navigationItem.title = [self.folderNames objectAtIndex:indexPath.row];
    }
}

- (NSIndexPath*) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == self.folderNames.count - 1)
        return nil;
    return indexPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *img = [UIImage imageNamed:@"folder.png"];
    [self.folderImage setImage:img];
    
    self.folderNames = [[NSMutableArray alloc] init];

    //Ahmed's code
    dbAccess = [[DatabaseAccessors alloc] init];
    [self->dbAccess initializeDatabase];
    self.folderNames = [self->dbAccess loadNamesFromDatabase];
    [self insertAddRowIntoArray];
    [self.tableView reloadData];
    //Ahmed's code end
    
    //ETHAN'S LINE OF CODE
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    setupButton = [[UIBarButtonItem alloc] initWithTitle:@"Setup" style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(setupAlert)];
    
}

//CALL THIS METHOD WHENEVER CHANGING THE SIZE OF THE TABLE
- (void) insertAddRowIntoArray
{
    [self.folderNames addObject:@""];
}


//////START BRIAN'S CODE

/*- (BOOL)shouldAutorotate
{
    return YES;
}*/

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

//////END BRIAN'S CODE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.folderNames count];
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
        
    return cell;
}

//Edit:Insert, Reorder and Delete
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
        //database call?
        [self->dbAccess deleteFolder:[self.folderNames objectAtIndex:indexPath.row]];
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

//MITCH CODE END

//AHMED CODE START

/*//Database stuff starts here - Ahmed

//Loads a list of all folder names into the folderNames array
- (void) loadNamesFromDatabase
{
    NSString *querySQL = [NSString stringWithFormat:@"SELECT name from folders;"];
    [self.folderNames addObjectsFromArray:[self executeSQL:querySQL ReturningRows:1]];
    [self insertAddRowIntoArray];
    [self.tableView reloadData];
}

//Saves a given folder name into the folders table.
- (void)saveNameInDatabase:(NSString *)theName {
    NSString *insertSQL = [NSString stringWithFormat:@"insert into folders values(\"%@\");", theName];
    [self executeSQL:insertSQL];
}

//Deletes a given folder from the folders table. Also deletes all tasks in that folder, and all completedTasks from that folder.
- (void) deleteFolder:(NSString *) theName {
    NSString *insertSQL = [NSString stringWithFormat:@"delete from folders where name = \"%@\";", theName];
    [self executeSQL:insertSQL];
    insertSQL = [NSString stringWithFormat:@"delete from tasks where folder = \"%@\";", theName];
    [self executeSQL:insertSQL];
    insertSQL = [NSString stringWithFormat:@"delete from completedtasks where folder = \"%@\";", theName];
    [self executeSQL:insertSQL];
}

//Prepares the database for change. Probably magic.
- (void)prepareDatabase {
    NSError *err=nil;
    NSFileManager *fm=[NSFileManager defaultManager];
    
    NSArray *arrPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, -1);
    NSString *path=[arrPaths objectAtIndex:0];
    NSString *path2= [path stringByAppendingPathComponent:@"atmadatabase.sql"];
    
    
    if(![fm fileExistsAtPath:path2])
    {
        
        bool success=[fm copyItemAtPath:databasePath toPath:path2 error:&err];
        if(success)
            NSLog(@"file copied successfully");
        else
            NSLog(@"file not copied");
        
    }
}

- (void) executeSQL:(NSString*) theStatement
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    [self prepareDatabase];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        const char *query_stmt = [theStatement UTF8String];
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}

- (NSMutableArray *) executeSQL:(NSString*) theStatement ReturningRows:(int)numRows
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray* allRows;
    NSArray* row;
    NSString* stringArray[numRows];
    
    allRows = [[NSMutableArray alloc] init];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        const char *query_stmt = [theStatement UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (numRows == 1)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString * obj = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    [allRows addObject:obj];
                }
            } else {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    for (int i  = 0; i < numRows; i++)
                    {
                        stringArray[i] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i)];
                        printf("%s\n", [stringArray[i] UTF8String]);
                    }
                    
                    row = [NSArray arrayWithObjects:stringArray count:numRows];
                    [allRows addObject:row];
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
    return allRows;
}
 
//Database stuff ends here*/

//AHMED CODE END


@end

///////MITCH'S CODE END
