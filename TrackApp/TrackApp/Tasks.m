//
//  Tasks.m
//  TrackApp
//
//  Created by Veatch, James E on 5/8/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "Tasks.h"

static int loadNamesCallback(void *context, int count, char **values, char **columns)
{
    NSMutableArray *names = (__bridge NSMutableArray *)context;
    for (int i=0; i < count; i++) {
        const char *nameCString = values[i];
        [names addObject:[NSString stringWithUTF8String:nameCString]];
    }
    return SQLITE_OK;
}

@implementation Tasks

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
    [DatabaseAccessors initializeDatabase];
    
    folderName = self.navigationItem.title;
    taskNames = [[NSMutableArray alloc] init];
    visibleBools = [[NSMutableArray alloc] init];
    taskTargets = [[NSMutableArray alloc] init];
    taskCurrents = [[NSMutableArray alloc] init];
    taskEndDates = [[NSMutableArray alloc] init];
    taskPeriods = [[NSMutableArray alloc] init];
    [self loadTasksFromDatabase];
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    resetTasksButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                     target:self
                                                                     action:@selector(resetTasksButtonTouched)];

}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    [self setEditing:FALSE animated:FALSE];
    [self loadTasksFromDatabase];
    [self.tableView reloadData];
}

//CALL THIS METHOD WHENEVER CHANGING THE SIZE OF THE TABLE
- (void) insertAddRowIntoArray
{
    [taskNames addObject:@""];
    [visibleBools addObject:@""];
    [taskTargets addObject:[NSNumber numberWithInteger:0]];
    [taskCurrents addObject:[NSNumber numberWithInteger:0]];
    [taskEndDates addObject:@""];
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

- (void) editTaskButtonTouched:(NSInteger*) index
{
    UIStoryboard*  sb;
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"] || [[UIDevice currentDevice].model isEqualToString:@"iPad_Simulator"]){
        sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    } else {
        sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    }
    
    CreateTaskViewController* vc = [sb instantiateViewControllerWithIdentifier:@"CreateTaskViewController"];
    [vc setFolderName:folderName];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc setTitle:@"Edit Task"];
    [vc setEditingTask:TRUE];
    [vc populateFields:[taskNames objectAtIndex:index] WithUnits:[taskUnits objectAtIndex:index] WithGoal:[taskTargets objectAtIndex:index] WithRecurrance:[taskPeriods  objectAtIndex:index] EndingOn:[[DatabaseAccessors retrieveValue:@"enddate" FromTask:[taskNames objectAtIndex:index] FromFolder:folderName] doubleValue]];
}

- (void) resetTaskButtonTouched:(NSInteger*) index
{
    selectedTaskName = [taskNames objectAtIndex:index];
    
    int period = [[taskPeriods objectAtIndex:index] integerValue];
    
    [DatabaseAccessors resetTaskWithName:selectedTaskName FromFolder:self.navigationItem.title];
    [DatabaseAccessors resetPeriod:period ForTaskWithName:selectedTaskName FromFolder:self.navigationItem.title];
    [self loadTasksFromDatabase];
    [self.tableView reloadData];
    
}

- (void) resetTasks
{
    for(int i=0; i<taskCurrents.count; i++){
        [taskCurrents replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0]];
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

- (void) resetTasksButtonTouched
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset All Tasks?" message:@"" delegate:self cancelButtonTitle:@"Don't Reset" otherButtonTitles: @"Reset", nil];
    alert.tag = TAG_RESET_ALL;
    
    [alert show];
}

- (void) incrementTask:(UIButton*)button
{
    float newCurrentFloat = [[taskCurrents objectAtIndex:button.tag] floatValue] + 1;

    NSNumber* newCurrent = [NSNumber numberWithFloat:newCurrentFloat];
    [taskCurrents replaceObjectAtIndex:button.tag withObject:newCurrent];
    [DatabaseAccessors incrementTaskWithName:[taskNames objectAtIndex:button.tag] FromFolder:self.navigationItem.title];
    [self.tableView reloadData];
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
    NSNumber* newCurrent = [NSNumber numberWithFloat:newCurrentFloat];
    [taskCurrents replaceObjectAtIndex:index withObject:newCurrent];
    [DatabaseAccessors incrementTaskWithName:[taskNames objectAtIndex:index] WithValue:newCurrentFloat FromFolder:self.navigationItem.title];
    [self.tableView reloadData];

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [taskNames count];
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
    
    cell.taskName.text = [taskNames
                          objectAtIndex: [indexPath row]];
    cell.taskTotal = [taskTargets
                      objectAtIndex:[indexPath row]];
    
    float current =[[taskCurrents objectAtIndex:[indexPath row]] floatValue];
    float total = [[taskTargets objectAtIndex:[indexPath row]] floatValue];
    NSString* currentStr = [NSString stringWithFormat:@"%.0f", current];
    NSString* totalStr = [NSString stringWithFormat:@"%.0f", total];
    
    cell.progress.progress = current/total;
    cell.progressText.text = [NSString stringWithFormat:@"%@/%@", currentStr, totalStr];
    [visibleBools addObject:cell.plusButton];
    [visibleBools addObject:cell.cellButton];
    if([visibleBools objectAtIndex: [indexPath row]] == @"true"){
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
    
    cell.dateLabel.text = [taskEndDates
                           objectAtIndex: [indexPath row]];
    
    [cell.progress setHidden:FALSE];
    [cell.plusButton setHidden:FALSE];
    [cell.progressText setHidden:FALSE];
    [cell.dateLabel setHidden:FALSE];
    if([indexPath row] == taskNames.count - 1){
        [cell.progress setHidden:TRUE];
        [cell.plusButton setHidden:TRUE];
        [cell.progressText setHidden:TRUE];
        [cell.dateLabel setHidden:TRUE];
    }
    
    return cell;
}

//Edit
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == taskNames.count - 1){
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
        [DatabaseAccessors deleteTaskWithName:[taskNames objectAtIndex:indexPath.row] FromFolder:self.navigationItem.title];
        [taskNames removeObjectAtIndex:indexPath.row];
        [taskPeriods removeObjectAtIndex:indexPath.row];
        [taskCurrents removeObjectAtIndex:indexPath.row];
        [taskEndDates removeObjectAtIndex:indexPath.row];
        [visibleBools removeObjectAtIndex:indexPath.row];
        [taskTargets removeObjectAtIndex:indexPath.row];
        [taskUnits removeObjectAtIndex:indexPath.row];
        
        [tableView reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        [self newTaskButtonTouched];
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == taskNames.count - 1)
        return NO;
    
    return YES;
}

//Reorder
- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if(destinationIndexPath.row >= taskNames.count - 1){
        [self.tableView reloadData];
        return;
    }
    NSString *toMoveAbove;
    if (destinationIndexPath.row >= [taskNames count]-2)
    {
        toMoveAbove = @"";
    } else if (sourceIndexPath.row < destinationIndexPath.row) {
        toMoveAbove = [taskNames objectAtIndex:destinationIndexPath.row+1];
    } else {
        toMoveAbove = [taskNames objectAtIndex:destinationIndexPath.row];
    }
    NSString* nameToMove = [taskNames objectAtIndex:sourceIndexPath.row];
    [taskNames removeObjectAtIndex:sourceIndexPath.row];
    [taskNames insertObject:nameToMove atIndex:destinationIndexPath.row];
    
    NSNumber* currentToMove = [taskCurrents objectAtIndex:sourceIndexPath.row];
    [taskCurrents removeObjectAtIndex:sourceIndexPath.row];
    [taskCurrents insertObject:currentToMove atIndex:destinationIndexPath.row];
    
    NSString* endDateToMove = [taskEndDates objectAtIndex:sourceIndexPath.row];
    [taskEndDates removeObjectAtIndex:sourceIndexPath.row];
    [taskEndDates insertObject:endDateToMove atIndex:destinationIndexPath.row];
    
    NSNumber* targetToMove = [taskTargets objectAtIndex:sourceIndexPath.row];
    [taskTargets removeObjectAtIndex:sourceIndexPath.row];
    [taskTargets insertObject:targetToMove atIndex:destinationIndexPath.row];
    
    NSString* visibleBoolToMove = [visibleBools objectAtIndex:sourceIndexPath.row];
    [visibleBools removeObjectAtIndex:sourceIndexPath.row];
    [visibleBools insertObject:visibleBoolToMove atIndex:destinationIndexPath.row];
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
    
    [taskNames removeAllObjects];
    [taskUnits removeAllObjects];
    [taskPeriods removeAllObjects];
    [taskEndDates removeAllObjects];
    [taskCurrents removeAllObjects];
    [taskTargets removeAllObjects];
    [visibleBools removeAllObjects];
    
    for (int i = 0; i < [tasks count]; i++)
    {
        [taskNames addObject:[[tasks objectAtIndex:i] objectAtIndex:0]];
        [taskUnits addObject:[[tasks objectAtIndex:i] objectAtIndex:1]];
        [taskPeriods addObject:[[tasks objectAtIndex:i] objectAtIndex:2]];
        [taskEndDates addObject:[self DayFormat:[[[tasks objectAtIndex:i] objectAtIndex:3] integerValue]]];
        [taskCurrents addObject:[[tasks objectAtIndex:i] objectAtIndex:4]];
        [taskTargets addObject:[[tasks objectAtIndex:i] objectAtIndex:5]];
        [visibleBools addObject:@"false"];
    }
    
    [self insertAddRowIntoArray];
    
}

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




@end
