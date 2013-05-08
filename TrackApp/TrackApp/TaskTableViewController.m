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

#define TAG_INCREMENT 1
#define TAG_RESET_ALL 2
#define TAG_TASK_CHANGE 3

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
    [super viewDidLoad];
    
    
    [DatabaseAccessors initializeDatabase];
    
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
    //[self insertAddRowIntoArray];
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
    [DatabaseAccessors resetTasksFromDatabaseFolder:self.navigationItem.title];
    [self.tableView reloadData];
}

- (void) newTaskButtonTouched
{    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    CreateTaskViewController* vc = [sb instantiateViewControllerWithIdentifier:@"CreateTaskViewController"];
    [vc setFolderName:folderName];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) resetTaskButtonTouched:(NSInteger*) index
{
    selectedTaskName = [taskNames objectAtIndex:index];
    
    //printf("New Period Data: %s.\n", [[_taskPeriods objectAtIndex:index] UTF8String]);
    //TODO
    int period = [[self.taskPeriods objectAtIndex:index] integerValue];
    
    [DatabaseAccessors resetTaskWithName:selectedTaskName FromFolder:self.navigationItem.title];
    //printf("About to reset time period with value %s.\n", [_taskPeriods objectAtIndex:index]);
    [DatabaseAccessors resetPeriod:period ForTaskWithName:selectedTaskName FromFolder:self.navigationItem.title];
    //NOTE: HIGHLY INELEGANT SOLUTION, TAKES SOME TIME
    [self loadTasksFromDatabase];
    [self.tableView reloadData];
    
}

- (void) editTaskButtonTouched:(NSInteger*) index
{
    NSString *querySQL = [NSString stringWithFormat:@"SELECT name, units, period, enddate, current, target from tasks where folder = \"%s\" order by priority ASC;", [self.navigationItem.title UTF8String]];
    NSMutableArray* rows = [DatabaseAccessors executeSQL:querySQL ReturningRows:6];
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    CreateTaskViewController* vc = [sb instantiateViewControllerWithIdentifier:@"CreateTaskViewController"];
    [vc setFolderName:folderName];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc setTitle:@"Edit Task"];
    [vc setEditingTask:TRUE];
    [vc populateFields:[taskNames objectAtIndex:index] WithUnits:[_taskUnits objectAtIndex:index] WithGoal:[_taskTargets objectAtIndex:index] WithRecurrance:[_taskPeriods  objectAtIndex:index] EndingOn:[[[rows objectAtIndex:index] objectAtIndex:3] integerValue]];
    //[vc populateFields:folderName];
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
    [cell.cellButton addTarget:self action:@selector(taskEditAlert:) forControlEvents:UIControlEventTouchUpInside];
    //Task Edit Long Press
//    UILongPressGestureRecognizer *editLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(taskEditAlert:)];
//    editLongPress.minimumPressDuration=1.0;
//    [cell.cellButton addGestureRecognizer:editLongPress];
    
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

- (void) incrementTask:(UIButton*)button
{
    float newCurrentFloat = [[self.taskCurrents objectAtIndex:button.tag] floatValue] + 1;
    //Used to stop incrementation past the threshhold
    //if(newCurrentFloat <= [[self.taskTargets objectAtIndex:button.tag] floatValue]){
        NSNumber* newCurrent = [NSNumber numberWithFloat:newCurrentFloat];
        [self.taskCurrents replaceObjectAtIndex:button.tag withObject:newCurrent];
    [DatabaseAccessors incrementTaskWithName:[self.taskNames objectAtIndex:button.tag] FromFolder:self.navigationItem.title];
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
    [DatabaseAccessors incrementTaskWithName:[self.taskNames objectAtIndex:index] WithValue:newCurrentFloat FromFolder:self.navigationItem.title];
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
        [DatabaseAccessors deleteTaskWithName:[self.taskNames objectAtIndex:indexPath.row] FromFolder:self.navigationItem.title];
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
    [DatabaseAccessors moveTaskWithName:nameToMove AboveTaskWithName:toMoveAbove FromFolder:self.navigationItem.title];
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
 
 - (void) loadTasksFromDatabase
{
    NSMutableArray* tasks = [DatabaseAccessors loadTasksFromDatabaseForFolder:self.navigationItem.title];
    
    [self.taskNames removeAllObjects];
    [self.taskUnits removeAllObjects];
    [self.taskPeriods removeAllObjects];
    [self.taskEndDates removeAllObjects];
    [self.taskCurrents removeAllObjects];
    [self.taskTargets removeAllObjects];
    [self.visibleBools removeAllObjects];
    
    for (int i = 0; i < [tasks count]; i++)
    {
        [self.taskNames addObject:[[tasks objectAtIndex:i] objectAtIndex:0]];
        [self.taskUnits addObject:[[tasks objectAtIndex:i] objectAtIndex:1]];
        [self.taskPeriods addObject:[[tasks objectAtIndex:i] objectAtIndex:2]];
        [self.taskEndDates addObject:[self DayFormat:[[[tasks objectAtIndex:i] objectAtIndex:3] integerValue]]];
        [self.taskCurrents addObject:[[tasks objectAtIndex:i] objectAtIndex:4]];
        [self.taskTargets addObject:[[tasks objectAtIndex:i] objectAtIndex:5]];
        [self.visibleBools addObject:@"false"];
    }
    
    [self insertAddRowIntoArray];
    
}
//AHMED CODE END*/

-(NSString *) DayFormat:(double) time
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
    NSDate *today=[NSDate date];
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:today];
    today = [calendar dateFromComponents:dateComponents];
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"MM/dd"];
    return [myFormatter stringFromDate:date];
    
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end

///////MITCH CODE END