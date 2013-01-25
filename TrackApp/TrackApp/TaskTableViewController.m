//
//  TaskTableViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import "TaskTableViewController.h"
#import "TaskTableViewCell.h"
#import "CreateTaskViewController.h"

//MITCH CODE END

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

@implementation TaskTableViewController
@synthesize taskNames, visibleBools, status;

- (void)viewDidLoad
{
    /*
    //Stuff for initializing the database -Ahmed
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:DATABASE_NAME]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:databasePath] == NO)
    {
        const char * dbPath = [databasePath UTF8String];
        
        if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "BLAH"; //Change to the real name
            
            if (sqlite3_exec(atmaDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                status.text = @"Failed to create Tasks table";
            }
            
            sqlite3_close(atmaDB);
        } else {
            status.text = @"Failed to open/create database";
        }
        
    }
    
    //[filemgr release];
    //The DB stuff ends here */
    
    [super viewDidLoad];
    
    self.taskNames = [[NSMutableArray alloc]
                      initWithObjects:@"wake up", @"eat",
                      @"go to sleep", nil];
    self.visibleBools = [[NSMutableArray alloc]
                         initWithObjects:@"false", @"false", @"false", nil];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    newTaskButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                  target:self
                                                                  action:@selector(newTaskButtonTouched)];
    folderName = self.navigationItem.title;
    
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    //[self loadTasksFromDatabase];
    //Update the TableView
    [self.tableView reloadData];
}

- (void) newTaskButtonTouched
{    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
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
    [self.visibleBools addObject:cell.plusButton];
    if([self.visibleBools objectAtIndex: [indexPath row]] == @"true"){
        [UIView animateWithDuration:0.5
                                       delay:0.0
                                     options: UIViewAnimationCurveEaseInOut
                                  animations:^{cell.plusButton.alpha = 0.0;}
                                  completion:nil];
    }
    else{
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{cell.plusButton.alpha = 1.0;}
                         completion:nil];
    }
    //cell.progress.progress = 0.5;
    //cell.dateLabel.text = @"Feb 23";
    //cell.progressText.text = @"5/10";
    
        
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
        self.visibleBools = [[NSMutableArray alloc]
                             initWithObjects:@"true", @"true",
                             @"true", nil];
        [self.tableView reloadData];
    }
    else{
        self.navigationItem.leftBarButtonItem = nil;
        self.visibleBools = [[NSMutableArray alloc]
                             initWithObjects:@"false", @"false",
                             @"false", nil];
        [self.tableView reloadData];
    }
}

-(void)endAppearanceTransition{
    [super endAppearanceTransition];
    printf("????\n");
    [self.tableView reloadData];
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

- (void)incrementTaskWithName:(NSString*)theName WithValue:(int)theValue
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
        *current = *current+theValue;
        
        int *target = NULL;
        insertSQL = [NSString stringWithFormat:@"select target from tasks where name = \"%@\"", theName];
        b = [insertSQL UTF8String];
        sqlite3_exec(database, b, NULL, (int*)target, NULL);
        
        insertSQL = [NSString stringWithFormat:@"update tasks set current = %d where name = \"%@\"", *current, theName];
        b = [insertSQL UTF8String];
        sqlite3_exec(database, b, NULL, NULL, NULL);
        
        //Target has been reached
        if (*current >= *target)
        {
            //Do something
        }
    }
    sqlite3_close(database);
}

- (void)resetTaskWithName:(NSString*)theName
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
        NSString *insertSQL = [NSString stringWithFormat:@"update tasks set current = 0 where name = \"%@\"", theName];
        const char* b = [insertSQL UTF8String];
        sqlite3_exec(database, b, NULL, NULL, NULL);
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

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end

///////MITCH CODE END