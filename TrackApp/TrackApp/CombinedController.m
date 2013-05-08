//
//  CombinedController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 3/20/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "CombinedController.h"
#import "FolderTableViewCell.h"
#import "TaskTableViewController.h"
#import "CreateTaskViewController.h"
#import "AppDelegate.h"
#import "TaskDetailViewController.h"
#import "HelpDocController.h"

#define TAG_SETUP 1
#define TAG_NEWFOLDER 2

@interface CombinedController ()

- (void)newTaskButtonTouched;

@end

@implementation CombinedController
@synthesize folderImage = _folderImage;
@synthesize folderNames = _folderNames;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImage *img = [UIImage imageNamed:@"folder.png"];
    [self.folderImage setImage:img];
    
    self.folderNames = [[NSMutableArray alloc] init];
    
    [DatabaseAccessors initializeDatabase];
    self.folderNames = [DatabaseAccessors loadNamesFromDatabase];
    [self insertAddRowIntoArray];
    
    //[DatabaseAccessors loadTasksFromDatabaseForFolder:[self.folderNames objectAtIndex:0]];
    //[self loadNamesFromDatabase];
    
    setupButton = [[UIBarButtonItem alloc] initWithTitle:@"Setup" style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(setupAlert)];
    
    self.navigationItem.leftBarButtonItem = setupButton;
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:path];
    
}


- (void)newTaskButtonTouched
{
    UIViewController *navigationViewController = [self.splitViewController.viewControllers objectAtIndex:0];
    CreateTaskViewController *newTaskViewController = [[CreateTaskViewController alloc] initWithNibName:@"CreateTaskViewController" bundle:nil];
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:navigationViewController, newTaskViewController, nil];
    self.splitViewController.viewControllers = viewControllers;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
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
    //printf("%s!!!", [[self.folderNames objectAtIndex: [indexPath row]] textLabel]);
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navDetailVC = [self.splitViewController.viewControllers objectAtIndex:1];
    TaskDetailViewController *detailVC = navDetailVC.visibleViewController;
    
    detailVC.navigationItem.title = [self.folderNames objectAtIndex: [indexPath row]];
    [detailVC updateTaskTable:[self.folderNames objectAtIndex: [indexPath row]]];
}

/////////////All Pulled From FolderTableViewController.m/////////////
/////////////////////////////BELOW///////////////////////////////////

- (IBAction)setupAlert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Main Menu" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Settings", @"Help", @"About", nil];
    alert.tag = TAG_SETUP;
    
    [alert show];
}

- (void) insertAddRowIntoArray
{
    [self.folderNames addObject:@""];
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
            
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            HelpDocController* vc = [sb instantiateViewControllerWithIdentifier:@"HelpDocController"];
            [self.splitViewController.viewControllers[1] pushViewController:vc animated:YES];
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

//Database stuff ends here


@end
