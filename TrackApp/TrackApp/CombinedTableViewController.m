//
//  CombinedTableViewController.m
//  TrackApp
//
//  Created by Collins, Brian C on 1/22/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

//BRIAN CODE START

#import "CombinedTableViewController.h"
#import "TaskTableViewCell.h"
#import "FolderCollectionViewCell.h"
#import "CreateTaskViewController.h"

//GENERATED CODE START

@implementation CombinedTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Combined from Task and Folder versions
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Task portion
    self.taskNames = [[NSMutableArray alloc]
                      initWithObjects:@"wake up", @"eat",
                      @"go to sleep", nil];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    newTaskButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                  target:self
                                                                  action:@selector(newTaskButtonTouched)];
    folderName = self.navigationItem.title;
    
    // Folder portion
    UIImage *img = [UIImage imageNamed:@"folder.png"];
    [self.folderImage setImage:img];
    
    //[self loadNamesFromDatabase];
    
    self.folderNames = [[NSMutableArray alloc]
                        initWithObjects:@"Business",
                        @"Personal", nil];
    
    //ETHAN'S LINE OF CODE
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    newFolderButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                    target:self
                                                                    action:@selector(alert)];
    
    setupButton = [[UIBarButtonItem alloc] initWithTitle:@"Setup" style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(setupAlert)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

//GENERATED CODE END
///////////////////////////////////////////////////////
//CODE FROM TaskTVC.m BEGIN

//AHMED CODE START

//Apparently this code has to be up here. I don't know why - Ahmed
//This needs to be changed
static int loadNamesCallback(void *context, int count, char **values, char **columns)
{
    NSMutableArray *names = (__bridge NSMutableArray *)context;
    for (int i=0; i < count; i++) {
        const char *nameCString = values[i];
        [names addObject:[NSString stringWithUTF8String:nameCString]];
    }
    return SQLITE_OK;
}

//AHMED CODE END

//MITCH CODE START

@synthesize taskNames, status;

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    //[self loadTasksFromDatabase];
    //Update the TableView
    [self.tableView reloadData];
}

- (void) newTaskButtonTouched
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    CreateTaskViewController* vc = [sb instantiateViewControllerWithIdentifier:@"CreateTaskViewController"];
    [vc setFolderName:folderName];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.taskNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"taskTableCell";
    
    TaskTableViewCell *cell = [tableView
                               dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TaskTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.taskName.text = [self.taskNames
                          objectAtIndex: [indexPath row]];
    
    
    return cell;
}

//Edit and Delete
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.taskNames removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:animate];
    if(editing){
        self.navigationItem.leftBarButtonItem = newTaskButton;
    }
    else
        self.navigationItem.leftBarButtonItem = nil;
    
}

//Database stuff starts here - Ahmed
//AHMED CODE START

- (NSString *) getWritableDBPath {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:DATABASE_NAME];
}

- (void)loadTasksFromDatabase
{
    NSString *file = [self getWritableDBPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL success = [fileManager fileExistsAtPath:file];
    
	// If its not a local copy set it to the bundle copy
	if(!success) {
		//file = [[NSBundle mainBundle] pathForResource:DATABASE_TITLE ofType:@"db"];
		[self createEditableCopyOfDatabaseIfNeeded];
	}
    
    sqlite3 *database = NULL;
    if (sqlite3_open([file UTF8String], &database) == SQLITE_OK) {
        sqlite3_exec(database, "select name from tasks order by priority", loadNamesCallback, (__bridge void *)(self.taskNames), NULL);
        sqlite3_exec(database, "select units from tasks order by priority", loadNamesCallback, (__bridge void *)(self.taskUnits), NULL);
        sqlite3_exec(database, "select period from tasks order by priority", loadNamesCallback, (__bridge void *)(self.taskPeriods), NULL);
        sqlite3_exec(database, "select enddate from tasks order by priority", loadNamesCallback, (__bridge void *)(self.taskEndDates), NULL);
        sqlite3_exec(database, "select current from tasks order by priority", loadNamesCallback, (__bridge void *)(self.taskCurrents), NULL);
        sqlite3_exec(database, "select target from tasks order by priority", loadNamesCallback, (__bridge void *)(self.taskTargets), NULL);
    }
    sqlite3_close(database);
}

- (void)incrementTaskWithName:(NSString*)theName
{
    NSString *file = [self getWritableDBPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL success = [fileManager fileExistsAtPath:file];
    
	// If its not a local copy set it to the bundle copy
	if(!success) {
		//file = [[NSBundle mainBundle] pathForResource:DATABASE_TITLE ofType:@"db"];
		[self createEditableCopyOfDatabaseIfNeeded];
	}
    
    sqlite3 *database = NULL;
    if (sqlite3_open([file UTF8String], &database) == SQLITE_OK) {
        int *current = NULL;
        NSString *insertSQL = [NSString stringWithFormat:@"select current from tasks where name = \"%@\"", theName];
        const char* b = [insertSQL UTF8String];
        sqlite3_exec(database, b, NULL, (int*)current, NULL);
        *current = *current++;
        
        int *target = NULL;
        insertSQL = [NSString stringWithFormat:@"select target from tasks where name = \"%@\"", theName];
        b = [insertSQL UTF8String];
        sqlite3_exec(database, b, NULL, (int*)target, NULL);
        
        insertSQL = [NSString stringWithFormat:@"update tasks set current = %d where name = \"%@\"", *current, theName];
        b = [insertSQL UTF8String];
        sqlite3_exec(database, b, NULL, NULL, NULL);
        
        //Target has been reached
        if (*current == *target)
        {
            //Do something
        }
    }
    sqlite3_close(database);
}



-(void)createEditableCopyOfDatabaseIfNeeded
{
    // Testing for existence
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DATABASE_NAME];
	
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
        return;
	
    // The writable database does not exist, so copy the default to
    // the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath]
							   stringByAppendingPathComponent:DATABASE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath
								   toPath:writableDBPath
									error:&error];
    if(!success)
    {
        NSAssert1(0,@"Failed to create writable database file with Message : '%@'.",
				  [error localizedDescription]);
    }
}

//Database stuff ends here
//AHMED CODE END
///////MITCH CODE END

//CODE FROM TaskTVC.m END
///////////////////////////////////////////////////////
//CODE FROM FolderTVC.m BEGIN

//MITCH CODE START
#define TAG_SETUP 1
#define TAG_NEWFOLDER 2

@synthesize folderImage = _folderImage;
@synthesize folderNames = _folderNames;

- (IBAction)alert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Folder" message:@"Put in folder name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    folderNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
    [folderNameTextField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:folderNameTextField];
    alert.tag = TAG_NEWFOLDER;
    
    [alert show];
}

- (IBAction)createFolder{
    NSString *folderName = folderNameTextField.text;
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
            //Add name to database HERE
            [self.folderNames addObject:folderName];
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

/*//// TODO: Replace this with the non-segue code for getting the folder name
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showFolderTitle"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TaskTableViewController *destViewController = segue.destinationViewController;
        destViewController.navigationItem.title = [self.folderNames objectAtIndex:indexPath.row];
    }
}*/

//BRIAN CODE START
// CollectionView code

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.folderNames count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"folderCollectionCell";
    
    // This gets the CollectionView, which is the only child. (test this)
    FolderCollectionViewCell *cell = [[self.childViewControllers objectAtIndex: 0]
                                 dequeueReusableCellWithIdentifier:CellIdentifier];
    // TODO: Fix this error.
//    if (cell == nil) {
//        cell = [[FolderCollectionViewCell alloc]
//                initWithStyle:UITableViewCellStyleDefault
//                reuseIdentifier:CellIdentifier];
//    }
    
    // Configure the cell...
    cell.folderName.text = [self.folderNames
                            objectAtIndex: [indexPath item]];
    
    
    return cell;
}

//BRIAN CODE END
/*////////////////// Start TableView Comment
// TODO: Replace this with CollectionView code if necessary.

//Edit and Delete
// TODO: Change to CollectionView style.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.folderNames removeObjectAtIndex:indexPath.item];
        [tableView reloadData];
    }
}

// TODO: Put newFolderButton somewhere.
*////// End TableView comment

//MITCH CODE END

//AHMED CODE START

//Database stuff starts here - Ahmed

- (void)loadNamesFromDatabase
{
    NSString *file = [self getWritableDBPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL success = [fileManager fileExistsAtPath:file];
    
	// If its not a local copy set it to the bundle copy
	if(!success) {
		//file = [[NSBundle mainBundle] pathForResource:DATABASE_TITLE ofType:@"db"];
		[self createEditableCopyOfDatabaseIfNeeded];
	}
    
    sqlite3 *database = NULL;
    if (sqlite3_open([file UTF8String], &database) == SQLITE_OK) {
        sqlite3_exec(database, "select name from folders", loadNamesCallback, (__bridge void *)(self.folderNames), NULL);
        //Update the TableView
        [self.tableView reloadData];
    }
    sqlite3_close(database);
}

- (void)saveNameInDatabase:(NSString *)theName {
	
	// Copy the database if needed
	[self createEditableCopyOfDatabaseIfNeeded];
	
	NSString *filePath = [self getWritableDBPath];
	
	sqlite3 *database;
	
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		const char *sqlStatement = "insert into folders (name) VALUES (?)";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)    {
			sqlite3_bind_text( compiledStatement, 1, [theName UTF8String], -1, SQLITE_TRANSIENT);
		}
		if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
			NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}

//Database stuff ends here

//AHMED CODE END
///////MITCH'S CODE END

//CODE FROM FolderTVC.m END

@end

