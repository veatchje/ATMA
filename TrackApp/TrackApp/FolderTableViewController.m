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
            //Add name to database HERE
            [self.folderNames removeLastObject];
            [self.folderNames addObject:folderName];
            [self insertAddRowIntoArray];
            [self.tableView reloadData];
        }
    }
    else if(alertView.tag == TAG_SETUP){
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"About"]){
            UIAlertView *aboutAlert = [[UIAlertView alloc] initWithTitle:@"About" message:@"This is for Senior Project" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [aboutAlert show];
        }
        else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Settings"]){
            //What happens when you press the Settings Button
        }
        else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Help"]){
            //What happens when you press the Help Button
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



- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *img = [UIImage imageNamed:@"folder.png"];
    [self.folderImage setImage:img];
    
     
    //self.folderNames = [[NSMutableArray alloc]
    //                    initWithObjects:@"Business",
    //                    @"Personal", nil];
    
    
    //DB stuff, so this is my code -Ahmed
    NSString *docsDir;
    NSArray *dirPaths;
    
    self.folderNames = [[NSMutableArray alloc] init];
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:DATABASE_NAME]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    printf("Checking if file exists\n");
    if ([filemgr fileExistsAtPath:databasePath] == NO)
    {
        printf("Creating the database\n");
        const char * dbPath = [databasePath UTF8String];
        
        if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists folders(name TEXT);";
            
            if (sqlite3_exec(atmaDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create Folders table";
            } else {
                sqlite3_stmt *statement;
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO FOLDERS values (\"Business\")"];
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(atmaDB, insert_stmt, -1, &statement, NULL);
                
                if(sqlite3_step(statement) == SQLITE_DONE ) {
                    printf("Folder added");
                }
                
                insertSQL = [NSString stringWithFormat:@"INSERT INTO FOLDERS values (\"Pleasure\")"];
                insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(atmaDB, insert_stmt, -1, &statement, NULL);
                
                if(sqlite3_step(statement) == SQLITE_DONE ) {
                    printf("Folder added");
                }
            }
            
            
            sqlite3_close(atmaDB);
        } else {
            //status.text = @"Failed to open/create database";
        }
    }
    //[filemgr release];
    //[self populateDatabase];
    [self loadNamesFromDatabase];
    
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

//Database stuff starts here - Ahmed
- (void) loadNamesFromDatabase
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT name from folders;"];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *nameField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [self.folderNames addObject:nameField];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
    [self insertAddRowIntoArray];
    [self.tableView reloadData];
}

- (void)saveNameInDatabase:(NSString *)theName {
	
    const char *filePath = [databasePath UTF8String];
    
    sqlite3_stmt *statement;
	
	if(sqlite3_open(filePath, &atmaDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into folders values(\"%@\");", theName];
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(atmaDB, insert_stmt, -1, &statement, NULL);
        
        if(sqlite3_step(statement) == SQLITE_DONE ) {
			printf("Folder added\n");
		}
        sqlite3_finalize(statement);
        sqlite3_close(atmaDB);
    }
}

- (void)populateDatabase {
	
	[self saveNameInDatabase:@"Business"];
    [self saveNameInDatabase:@"Pleasure"];
}


 
//Database stuff ends here

//AHMED CODE END


@end

///////MITCH'S CODE END
