//
//  TaskDetailViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 3/20/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "TaskTableViewCell.h"
#import "CreateTaskViewController.h"
#import "AppDelegate.h"
#import "CombinedController.h"

#define TAG_INCREMENT 1
#define TAG_RESET_ALL 2
#define TAG_TASK_CHANGE 3

@interface TaskDetailViewController ()

@end

@implementation TaskDetailViewController

@synthesize toolbar, taskNames, visibleBools, status;


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
        printf("In viewDidLoad, table does not exist.\n");
        
        if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, units TEXT, folder TEXT, period INTEGER, enddate TIME, current INTEGER, target INTEGER, priority INTEGER);";
            
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
    
    
    folderName = self.navigationItem.title;
    //Initialize the arrays, call the database
    self.taskNames = [[NSMutableArray alloc] init];
    self.visibleBools = [[NSMutableArray alloc] init];
    self.taskTargets = [[NSMutableArray alloc] init];
    self.taskCurrents = [[NSMutableArray alloc] init];
    self.taskEndDates = [[NSMutableArray alloc] init];
    self.taskPeriods = [[NSMutableArray alloc] init];
    [self loadTasksFromDatabase];
    //[self insertAddRowIntoArray];
    [self.tableView reloadData];
    //end initialization
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    resetTasksButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                     target:self
                                                                     action:@selector(resetTasksButtonTouched)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Folders";
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    masterPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
    self.navigationItem.leftBarButtonItem = nil;
    
    masterPopoverController = nil;
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
    cell.taskTotal = [self.taskTargets
                      objectAtIndex:[indexPath row]];
    
    float current =[[self.taskCurrents objectAtIndex:[indexPath row]] floatValue];
    float total = [[self.taskTargets objectAtIndex:[indexPath row]] floatValue];
    NSString* currentStr = [NSString stringWithFormat:@"%.0f", current];
    NSString* totalStr = [NSString stringWithFormat:@"%.0f", total];
    
    cell.progress.progress = current/total;
    cell.progressText.text = [NSString stringWithFormat:@"%@/%@", currentStr, totalStr];
    [self.visibleBools addObject:cell.plusButton];
    [self.visibleBools addObject:cell.cellButton];
    if([self.visibleBools objectAtIndex: [indexPath row]] == @"true"){
        cell.plusButton.alpha = 0.0;
    }
    else{
        cell.plusButton.alpha = 1.0;
    }
    
    cell.plusButton.tag = indexPath.row;
    cell.cellButton.tag = indexPath.row;
    [cell.plusButton addTarget:self action:@selector(incrementTask:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.plusButton addTarget:self action:@selector(plusButtonHelper:) forControlEvents:UIControlEventTouchDown];
    
    [cell.cellButton addTarget:self action:@selector(cellIndexHelper:) forControlEvents:UIControlEventTouchDown];
    
    //Task Edit Long Press
    UILongPressGestureRecognizer *editLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(taskEditAlert:)];
    editLongPress.minimumPressDuration=1.0;
    [cell.cellButton addGestureRecognizer:editLongPress];
    
    //Custom Increment Long Press
    UILongPressGestureRecognizer *incremenLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(taskAlert:)];
    incremenLongPress.minimumPressDuration=1.0;
    [cell.plusButton addGestureRecognizer:incremenLongPress];
    
    
    if(cell.progress.progress < 0.40){
        cell.progress.progressTintColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    }
    else if(current/total >= 0.40 && current/total < 0.80){
        cell.progress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:1];
    }
    else if(current/total >= 0.80 && current/total <= 1){
        cell.progress.progressTintColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    }
    else if(current/total >= 1){
        cell.progress.progressTintColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];
    }
    
    cell.dateLabel.text = [self.taskEndDates
                           objectAtIndex: [indexPath row]];
    
    [cell.progress setHidden:FALSE];
    [cell.plusButton setHidden:FALSE];
    [cell.progressText setHidden:FALSE];
    [cell.dateLabel setHidden:FALSE];
    if([indexPath row] == self.taskNames.count - 1){
        [cell.progress setHidden:TRUE];
        [cell.plusButton setHidden:TRUE];
        [cell.progressText setHidden:TRUE];
        [cell.dateLabel setHidden:TRUE];
    }
    
    return cell;
}

- (void) updateTaskTable:(NSString *) folder
{
    [self loadTaskNamesFromDatabase:folder];
    //Update the TableView
    [self.tableView reloadData];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

/////////////All Pulled From TaskTableViewController.m/////////////
/////////////////////////////BELOW///////////////////////////////////

static int loadNamesCallback(void *context, int count, char **values, char **columns)
{
    NSMutableArray *names = (__bridge NSMutableArray *)context;
    for (int i=0; i < count; i++) {
        const char *nameCString = values[i];
        [names addObject:[NSString stringWithUTF8String:nameCString]];
    }
    return SQLITE_OK;
}

- (void) newTaskButtonTouched
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    CreateTaskViewController* vc = [sb instantiateViewControllerWithIdentifier:@"CreateTaskViewController"];
    [vc setFolderName:folderName];
    [self.navigationController pushViewController:vc animated:YES];
}

//CALL THIS METHOD WHENEVER CHANGING THE SIZE OF THE TABLE
- (void) insertAddRowIntoArray
{
    [self.taskNames addObject:@""];
    [self.visibleBools addObject:@""];
    [self.taskTargets addObject:[NSNumber numberWithInteger:0]];
    [self.taskCurrents addObject:[NSNumber numberWithInteger:0]];
    [self.taskEndDates addObject:@""];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    [self setEditing:FALSE animated:FALSE];
    [self loadTasksFromDatabase];
    //Update the TableView
    [self.tableView reloadData];
}

- (void) resetTasksButtonTouched
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset All Tasks?" message:@"" delegate:self cancelButtonTitle:@"Don't Reset" otherButtonTitles: @"Reset", nil];
    alert.tag = TAG_RESET_ALL;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == TAG_RESET_ALL){
        if(buttonIndex != [alertView cancelButtonIndex]){
            [self resetTasks];
        }
    }
    else if(alertView.tag == TAG_INCREMENT){
        if(buttonIndex != [alertView cancelButtonIndex]){
            float newNumb = [taskNumberTextField.text floatValue];
            [self incrementTaskLong:newNumb plusButtonIndex:plusButtonIndex];
        }
    }
    else if(alertView.tag == TAG_TASK_CHANGE){
        if(buttonIndex == 1){
            //Reset Task Progress
            printf("Reset Task\n");
            [self resetTaskButtonTouched:cellIndex];
            //error;
        }
        else if(buttonIndex == 2){
            //Edit Task
            //printf("Editing task\n");
            [self editTaskButtonTouched:cellIndex];
            //error;
        }
    }
}

- (void) resetTasks
{
    for(int i=0; i<self.taskCurrents.count; i++){
        [self.taskCurrents replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0]];
    }
    [self resetTasksFromDatabase];
    [self.tableView reloadData];
}

- (void) resetTaskButtonTouched:(NSInteger*) index
{
    selectedTaskName = [taskNames objectAtIndex:index];
    
    //printf("New Period Data: %s.\n", [[_taskPeriods objectAtIndex:index] UTF8String]);
    //TODO
    int period = [[_taskPeriods objectAtIndex:index] integerValue];
    
    [self resetTaskWithName:selectedTaskName];
    //printf("About to reset time period with value %s.\n", [_taskPeriods objectAtIndex:index]);
    [self resetPeriod:period ForTaskWithName:selectedTaskName];
    //NOTE: HIGHLY INELEGANT SOLUTION, TAKES SOME TIME
    [self loadTasksFromDatabase];
    [self.tableView reloadData];
    
}

- (void) editTaskButtonTouched:(NSInteger*) index
{
    printf("hello?");
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    CreateTaskViewController* vc = [sb instantiateViewControllerWithIdentifier:@"CreateTaskViewController"];
    [vc setFolderName:folderName];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc setTitle:@"Edit Task"];
    [vc setEditingTask:TRUE];
    [vc populateFields:[taskNames objectAtIndex:index] WithUnits:[_taskUnits objectAtIndex:index] WithGoal:[_taskTargets objectAtIndex:index] WithRecurrance:[_taskPeriods  objectAtIndex:index] EndingOn:[_taskEndDates  objectAtIndex:index]];
    //[vc populateFields:folderName];
}

- (void) incrementTask:(UIButton*)button
{
    float newCurrentFloat = [[self.taskCurrents objectAtIndex:button.tag] floatValue] + 1;
    //Used to stop incrementation past the threshhold
    //if(newCurrentFloat <= [[self.taskTargets objectAtIndex:button.tag] floatValue]){
    NSNumber* newCurrent = [NSNumber numberWithFloat:newCurrentFloat];
    [self.taskCurrents replaceObjectAtIndex:button.tag withObject:newCurrent];
    [self incrementTaskWithName:[self.taskNames objectAtIndex:button.tag]];
    [self.tableView reloadData];
    //}
}

- (void) plusButtonHelper: (UIButton*)button
{
    plusButtonIndex = button.tag;
}

- (void) cellIndexHelper: (UIButton*) cellButton
{
    cellIndex = cellButton.tag;
}

- (void) taskAlert:(UILongPressGestureRecognizer*)sender
{
    if(taskAlertView == nil){
        taskAlertView = [[UIAlertView alloc] initWithTitle:@"New Task Progress" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        taskNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        [taskNumberTextField setBackgroundColor:[UIColor whiteColor]];
        taskNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
        [taskAlertView addSubview:taskNumberTextField];
        taskAlertView.tag = TAG_INCREMENT;
        [taskAlertView show];
        [taskNumberTextField becomeFirstResponder];
        taskAlertView = nil;
    }
}

-(void) taskEditAlert:(UILongPressGestureRecognizer*)sender
{
    
    if(taskAlertView == nil){
        taskAlertView = [[UIAlertView alloc] initWithTitle:@"Select an option for this task" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset Task", @"Edit Task", nil];
        taskAlertView.tag = TAG_TASK_CHANGE;
        [taskAlertView show];
        taskAlertView = nil;
    }
}

- (void) incrementTaskLong:(float)newCurrentFloat plusButtonIndex:(NSInteger*) index
{
    //printf("%f swag %d", newCurrentFloat, (int)index);
    //Used to stop incrementation past the threshhold
    //if(newCurrentFloat <= [[self.taskTargets objectAtIndex:button.tag] floatValue]){
    NSNumber* newCurrent = [NSNumber numberWithFloat:newCurrentFloat];
    [self.taskCurrents replaceObjectAtIndex:index withObject:newCurrent];
    [self incrementTaskWithName:[self.taskNames objectAtIndex:index] WithValue:newCurrentFloat];
    [self.tableView reloadData];
    //}
}


//Edit: Insert, Reorder, and Delete

//Edit
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.taskNames.count - 1){
        return UITableViewCellEditingStyleInsert;
    }
    else{
        return UITableViewCellEditingStyleDelete;
    }
}

//Commit the edit
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteTaskWithName:[self.taskNames objectAtIndex:indexPath.row]];
        [self.taskNames removeObjectAtIndex:indexPath.row];
        [self.taskPeriods removeObjectAtIndex:indexPath.row];
        [self.taskCurrents removeObjectAtIndex:indexPath.row];
        [self.taskEndDates removeObjectAtIndex:indexPath.row];
        [self.visibleBools removeObjectAtIndex:indexPath.row];
        [self.taskTargets removeObjectAtIndex:indexPath.row];
        [self.taskUnits removeObjectAtIndex:indexPath.row];
        
        [tableView reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        [self newTaskButtonTouched];
        
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == self.taskNames.count - 1)
        return NO;
    
    return YES;
}

//Reorder
- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if(destinationIndexPath.row >= self.taskNames.count - 1){
        [self.tableView reloadData];
        return;
    }
    NSString *toMoveAbove;
    if (destinationIndexPath.row >= [self.taskNames count]-2)
    {
        toMoveAbove = @"";
    } else if (sourceIndexPath.row < destinationIndexPath.row) {
        toMoveAbove = [self.taskNames objectAtIndex:destinationIndexPath.row+1];
    } else {
        toMoveAbove = [self.taskNames objectAtIndex:destinationIndexPath.row];
    }
    NSString* nameToMove = [self.taskNames objectAtIndex:sourceIndexPath.row];
    [self.taskNames removeObjectAtIndex:sourceIndexPath.row];
    [self.taskNames insertObject:nameToMove atIndex:destinationIndexPath.row];
    
    NSNumber* currentToMove = [self.taskCurrents objectAtIndex:sourceIndexPath.row];
    [self.taskCurrents removeObjectAtIndex:sourceIndexPath.row];
    [self.taskCurrents insertObject:currentToMove atIndex:destinationIndexPath.row];
    
    NSString* endDateToMove = [self.taskEndDates objectAtIndex:sourceIndexPath.row];
    [self.taskEndDates removeObjectAtIndex:sourceIndexPath.row];
    [self.taskEndDates insertObject:endDateToMove atIndex:destinationIndexPath.row];
    
    NSNumber* targetToMove = [self.taskTargets objectAtIndex:sourceIndexPath.row];
    [self.taskTargets removeObjectAtIndex:sourceIndexPath.row];
    [self.taskTargets insertObject:targetToMove atIndex:destinationIndexPath.row];
    
    NSString* visibleBoolToMove = [self.visibleBools objectAtIndex:sourceIndexPath.row];
    [self.visibleBools removeObjectAtIndex:sourceIndexPath.row];
    [self.visibleBools insertObject:visibleBoolToMove atIndex:destinationIndexPath.row];
    //Save array of new order to database
    printf("First name: %s \t Second name: %s\n", [nameToMove UTF8String], [toMoveAbove UTF8String]);
    [self moveTaskWithName:nameToMove AboveTaskWithName:toMoveAbove];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:animate];
    if(editing){
        self.navigationItem.leftBarButtonItem = resetTasksButton;
        int count =visibleBools.count;
        [visibleBools removeAllObjects];
        for(int i = 0;i<count-1;i++){
            [visibleBools addObject:@"true"];
        }
        
        [self.tableView reloadData];
    }
    else{
        self.navigationItem.leftBarButtonItem = nil;
        int count =visibleBools.count;
        [visibleBools removeAllObjects];
        for(int i = 0;i<count-1;i++){
            [visibleBools addObject:@"false"];
        }
        [self.tableView reloadData];
    }
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
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT name, units, period, enddate, current, target from tasks where folder = \"%s\" order by priority ASC;", [self.navigationItem.title UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(atmaDB, query_stmt, -1, &statement, NULL) != SQLITE_OK)
        {
            printf("Now creating Tasks table.\n");
            char * errMsg;
            const char *sql_stmt = "create table if not exists tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, units TEXT, folder TEXT, period INTEGER, enddate TIME, current INTEGER, target INTEGER, priority INTEGER);";
            if (sqlite3_exec(atmaDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
            {
                printf("Task table creation statement was successful.\n");
                sqlite3_stmt *statement2;
                NSString *insertSQL2 = [NSString stringWithFormat:@"insert into tasks (name, units, folder, period, enddate, current, target, priority) values (\"Create Tasks\", \"tasks\", \"%s\", 7, 2013-2-13, 0, 1, 1);", [self.navigationItem.title UTF8String]];
                const char *insert_stmt2 = [insertSQL2 UTF8String];
                sqlite3_prepare_v2(atmaDB, insert_stmt2, -1, &statement2, NULL);
                printf("Everything is prepared.\n");
                if(sqlite3_step(statement2) == SQLITE_DONE ) {
                    printf("Task added");
                }
            }
        }
        
        if (sqlite3_prepare_v2(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            [self.taskNames removeAllObjects];
            [self.taskUnits removeAllObjects];
            [self.taskPeriods removeAllObjects];
            [self.taskEndDates removeAllObjects];
            [self.taskCurrents removeAllObjects];
            [self.taskTargets removeAllObjects];
            [self.visibleBools removeAllObjects];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *nameField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [self.taskNames addObject:nameField];
                
                NSString *unitsField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                [self.taskUnits addObject:unitsField];
                
                NSString *periodField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                [self.taskPeriods addObject:periodField];
                //printf("PeriodData: %s.\n", [periodField UTF8String]);
                
                NSString *endField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                [self.taskEndDates addObject:[self DayFormat:[endField integerValue]]];
                
                NSString *currentField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                [self.taskCurrents addObject:currentField];
                
                NSString *targetField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                [self.taskTargets addObject:targetField];
                
                [self.visibleBools addObject:@"false"];
            }
            sqlite3_finalize(statement);
        } else {
            printf("%d", sqlite3_prepare_v2(atmaDB, query_stmt, -1, &statement, NULL));
        }
        sqlite3_close(atmaDB);
    }
    [self insertAddRowIntoArray];
}

- (void)incrementTaskWithName:(NSString*)theName
{
    
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    [self prepareDatabase];
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"update tasks set current =current+1 where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [self.navigationItem.title UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //sqlite3_bind_text(*query_stmt, 1, [theName UTF8String], -1, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //Inrement successful!
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}

- (void)incrementTaskWithName:(NSString*)theName WithValue:(int)theValue
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    [self prepareDatabase];
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"update tasks set current =%d where name = \"%s\" and folder = \"%s\";", theValue, [theName UTF8String], [self.navigationItem.title UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //sqlite3_bind_int(*query_stmt, 1, theValue);
            //sqlite3_bind_text(*query_stmt, 2, [theName UTF8String], -1, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //Inrement successful!
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}

//This function resets the progress of a given task
- (void)resetTaskWithName:(NSString*)theName
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    [self prepareDatabase];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"update tasks set current =0 where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [self.navigationItem.title UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //Increment successful!
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}

//This function resets the progress of all the tasks in the given folder
- (void)resetTasksFromDatabase
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    [self prepareDatabase];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"update tasks set current =0 where folder = \"%s\";", [self.navigationItem.title UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //Increment successful!
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}

- (void)deleteTaskWithName:(NSString*)theName
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    [self prepareDatabase];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"delete from tasks where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [self.navigationItem.title UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) {
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}

- (void)resetPeriod:(int)thePeriod ForTaskWithName:(NSString*)theName
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    [self prepareDatabase];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        //No longer need to add current time, this code preserved in case of future need
        //NSDate* today = [NSDate date];
        //double seconds = [today timeIntervalSince1970];
        NSString *querySQL = [NSString stringWithFormat:@"update tasks set enddate = enddate + %d where name = \"%s\" and folder = \"%s\";", thePeriod*24*3600, [theName UTF8String], [self.navigationItem.title UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                printf("Time period reset was successful for task %s with period %d.", [theName UTF8String], thePeriod);
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}


-(void)moveTaskWithName:(NSString*)theFirstName AboveTaskWithName:(NSString*)theSecondName
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    [self prepareDatabase];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select priority from tasks where name = \"%s\" and folder = \"%s\";", [theSecondName UTF8String], [self.navigationItem.title UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        int priority = 0;
        if (![theSecondName isEqualToString:@""]) {
            
            querySQL = [NSString stringWithFormat:@"select priority from tasks where name = \"%s\" and folder = \"%s\";", [theSecondName UTF8String], [self.navigationItem.title UTF8String]];
            query_stmt = [querySQL UTF8String];
            if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                sqlite3_step(statement);
                NSString *priorityRaw = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(statement, 0)];
                priority = [priorityRaw intValue];
                sqlite3_finalize(statement);
            }
        } else {
            querySQL = [NSString stringWithFormat:@"select max(priority) from tasks where folder = \"%s\";", [self.navigationItem.title UTF8String]];
            query_stmt = [querySQL UTF8String];
            if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                sqlite3_step(statement);
                NSString *priorityRaw = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(statement, 0)];
                priority = [priorityRaw intValue] + 1;
                sqlite3_finalize(statement);
            }
            
        }
        
        
        querySQL = [NSString stringWithFormat:@"update tasks set priority = priority+1 where priority >= %d and folder = \"%s\";", priority, [self.navigationItem.title UTF8String]];
        query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //Incrementation successful!
            }
            sqlite3_finalize(statement);
        }
        
        querySQL = [NSString stringWithFormat:@"update tasks set priority = %d where name = \"%s\" and folder = \"%s\";", priority, [theFirstName UTF8String], [self.navigationItem.title UTF8String]];
        query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //Reprioritization successful!
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}

- (void)prepareDatabase {
    NSError *err=nil;
    NSFileManager *fm=[NSFileManager defaultManager];
    
    NSArray *arrPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, -1);
    NSString *path=[arrPaths objectAtIndex:0];
    NSString *path2= [path stringByAppendingPathComponent:@"ProductDatabase.sql"];
    
    
    if(![fm fileExistsAtPath:path2])
    {
        
        bool success=[fm copyItemAtPath:databasePath toPath:path2 error:&err];
        if(success)
            NSLog(@"file copied successfully");
        else
            NSLog(@"file not copied");
        
    }
}
     //This is used to grab names for export later to graph.
     - (NSMutableArray *) loadTaskNamesFromDatabase:(NSString *) theFolderName
    {
        const char *dbPath = [databasePath UTF8String];
        sqlite3_stmt *statement;
        NSMutableArray* names;
        
        names = [[NSMutableArray alloc] init];
        
        if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
        {
            NSString *querySQL = [NSString stringWithFormat:@"SELECT name from tasks where folder = \"%s\";", [theFolderName UTF8String]];
            const char *query_stmt = [querySQL UTF8String];
            
            if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    NSString *nameField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    [names addObject:nameField];
                }
                sqlite3_finalize(statement);
            }
            sqlite3_close(atmaDB);
        }
        return names;
    }


//Database stuff ends here
//AHMED CODE END

-(NSString *) DayFormat:(double) time
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
    NSDate *today=[NSDate date];
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:today];
    //printf("%f today1\n ",[today timeIntervalSince1970]);
    today = [calendar dateFromComponents:dateComponents];
    //printf("%f today2\n ",[today timeIntervalSince1970]);
    //printf("%f, time\n",time);
    //printf("%f",time-[today timeIntervalSince1970]);
    /*if ([today timeIntervalSince1970]+86399>=time && [today timeIntervalSince1970] < time) {
     return @"Today";
     }else if ([today timeIntervalSince1970]+2*86399+1>=time && [today timeIntervalSince1970]+86399<=time){
     return @"Tom.";
     
     }else{*/
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    //[myFormatter stringFromDate:Cdate]
    [myFormatter setDateFormat:@"MMM dd"];
    return [myFormatter stringFromDate:date];
    // }
    
    
}
@end
