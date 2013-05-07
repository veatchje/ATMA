//
//  CreateTaskViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import "CreateTaskViewController.h"

#define TAG_RECUR 1
#define TAG_CUSTOM 2

@interface CreateTaskViewController ()

@end

@implementation CreateTaskViewController
- (void) setFolderName: (NSString*) name {
    folderName = name;
}

- (IBAction)cancel {
    //Clear fields
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save {
    //Date is integer???
    if(taskName.text.length < 1 || goalNumber.text.length < 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please make sure that the task name and goal number are filled in." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    else{        
        //The idea here is to save it to the DB then load it once back at the Tasks screen
        //This boolean is true if we are editing an existing task
        if (editingTask)
        {
            [self deleteExistingTaskInDatabaseWithName:origTaskName withFolder:folderName];
        } else {
            progress = 0;
        }
        if ([self checkUniquenessForTaskInDatabaseWithName:taskName.text withFolder:folderName])
        {
            [self saveTaskInDatabaseWithName:taskName.text withUnits:unitName.text withFolder:folderName withPeriod:selectedRecur withDate:Cdate.timeIntervalSince1970 withTarget:[goalNumber.text intValue]];
            
            NSString *deviceType = [UIDevice currentDevice].model;
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A task with that name already exists in the folder." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void) setRecur: (id) sender {
    
    int period = [sender selectedSegmentIndex];
    switch (period) {
        case 0:
            selectedRecur = 1;
            break;
        case 1:
            selectedRecur = 7;
            break;
        case 2:
            
            if ([datePicker selectedRowInComponent:0]>=[datePicker numberOfRowsInComponent:0]-1) {
                printf("\ntest ");
                printf("%i",[datePicker selectedRowInComponent:0]);
                selectedRecur=-40;
                break;
            }
            else{
                selectedRecur=-1*[datePicker selectedRowInComponent:0];
                selectedRecur--;
                break;
            }
          
        case 3:
            [recurAlert show];
            break;
        default:
            selectedRecur = 0;
            break;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == TAG_RECUR){    
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"None"]){
            selectedRecur = 0;
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Custom"]){
            UIAlertView *customAlert = [[UIAlertView alloc] initWithTitle:@"Number of days:" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
            customRecurTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
            [customRecurTextField setBackgroundColor:[UIColor whiteColor]];
            customRecurTextField.keyboardType = UIKeyboardTypeNumberPad;
            [customAlert addSubview:customRecurTextField];
            customAlert.tag = TAG_CUSTOM;
            [customRecurTextField becomeFirstResponder];
            [customAlert show];
        } else {
            recurrence.selectedSegmentIndex = 0;
        }
    } else if(alertView.tag == TAG_CUSTOM){
        if (buttonIndex != [alertView cancelButtonIndex]) {
            selectedRecur = [customRecurTextField.text intValue];
        } else {
            recurrence.selectedSegmentIndex = 0;
        }
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setCdate:(double) time
{
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
    Cdate=date;
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    //[myFormatter stringFromDate:Cdate]
    [myFormatter setDateFormat:@"dd"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1  inComponent:0 animated:FALSE];
    [myFormatter setDateFormat:@"MM"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1 inComponent:1  animated:FALSE];
    [myFormatter setDateFormat:@"yyyy"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1 inComponent:2 animated:FALSE];}

- (void)viewDidLoad
{
    //scrollView.frame = CGRectMMake(0,0.320.460);
    [scrollview setScrollEnabled:NO];
    [scrollview setContentSize:CGSizeMake(320, 900)];
    if (Cdate==NULL) {
        Cdate=[NSDate date];
    }
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    //[myFormatter stringFromDate:Cdate]
    [myFormatter setDateFormat:@"dd"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1  inComponent:0 animated:FALSE];
    [myFormatter setDateFormat:@"MM"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1 inComponent:1  animated:FALSE];
    [myFormatter setDateFormat:@"yyyy"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1 inComponent:2 animated:FALSE];

    goalNumber.keyboardType = UIKeyboardTypeNumberPad;
    
    //adds the action listener to the recurence segemented control
    [recurrence addTarget:self action:@selector(setRecur:) forControlEvents:UIControlEventValueChanged];
    recurAlert = [[UIAlertView alloc] initWithTitle:@"Recurrence Options" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"None", @"Custom", nil];
    recurAlert.tag = TAG_RECUR;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [scrollview addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;  // this prevents the gesture recognizers to 'block' touches
    
    UIBarButtonItem *createTaskButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                     target:self
                                                                     action:@selector(save)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = createTaskButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    //Stuff for initializing the database -Ahmed
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:DATABASE_NAME]];
    
     //The DB stuff ends here
    selectedRecur = 1;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void) setEditingTask:(Boolean)editing
{
    editingTask = editing;
}

- (void)populateFields:(NSString*) currentTaskName WithUnits:(NSString*) currentUnits WithGoal:(NSString*) currentGoal WithRecurrance:(int) currentDays EndingOn:(double)currentEnd
{
    printf("Populating fields: %s\n",[currentTaskName UTF8String]);
    origTaskName = currentTaskName;
    taskPriority = 0;
    taskName.text = currentTaskName;
    unitName.text = currentUnits;
    goalNumber.text = currentGoal;
    [self setCdate:currentEnd];
//    switch (currentDays) {
//        case 7:
//            //daily
//            
//        default:
//            break;
//    }
    //datePicker
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *) theTextField{
    [theTextField resignFirstResponder];
    return YES;
}

- (void)hideKeyboard {
    [taskName resignFirstResponder];
    [unitName resignFirstResponder];
    [goalNumber resignFirstResponder];
}

-(IBAction)GetDateWithDay
{
//    NSDate *today = datePicker.date;
//    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
//    [myFormatter setDateFormat:@"EEEE"]; // day, like "Saturday"
//    
//    NSString *dayOfWeek = [myFormatter stringFromDate:today];
//    lblDate.text =dayOfWeek;

}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
    
    if (component == 0) {
        return [myCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:Cdate].length;
    }
    else if (component==1){
        return [myCalendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:Cdate].length;
    }
    return 3000;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
    if (component==0) {
        int month =[datePicker selectedRowInComponent:1]+1;
        int year = [datePicker selectedRowInComponent:2]+1;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:Cdate];
        
        [dateComponents setDay:row+1];
        NSDate *newDate = [calendar dateFromComponents:dateComponents];
        
        Cdate=newDate;
        [datePicker selectRow:row inComponent:0 animated:FALSE];
        [datePicker selectRow:month-1 inComponent:1 animated:FALSE];
        [datePicker selectRow:year-1 inComponent:2 animated:FALSE];
    }else if (component==1){
        int day= [datePicker selectedRowInComponent:0]+1;
        int year =[datePicker selectedRowInComponent:2]+1;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:Cdate];
        
        [dateComponents setMonth:row+1];
        [dateComponents setDay:1];
        NSDate *newDate = [calendar dateFromComponents:dateComponents];
        
        if ([myCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate].length>=day) {
            [dateComponents setDay:day];
        } else{
            [dateComponents setDay:[myCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate].length];
            day=[myCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate].length;
        }
        Cdate=newDate;
        [datePicker reloadAllComponents];
        [datePicker selectRow:day-1 inComponent:0 animated:FALSE];
        [datePicker selectRow:row inComponent:1 animated:FALSE];
        [datePicker selectRow:year-1 inComponent:2 animated:FALSE];
        
    }else{
        int day= [datePicker selectedRowInComponent:0]+1;
        int month =[datePicker selectedRowInComponent:1]+1;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:Cdate];
        
        [dateComponents setYear:row+1];
        [dateComponents setMonth:1];
        [dateComponents setDay:1];
        NSDate *newDate = [calendar dateFromComponents:dateComponents];
        if ([myCalendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:newDate].length>=month) {
            [dateComponents setMonth:month];
        } else{
            [dateComponents setMonth:[myCalendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:newDate].length];
            month=[myCalendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:newDate].length;
        }
        newDate = [calendar dateFromComponents:dateComponents];
        if ([myCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate].length>=day) {
            [dateComponents setDay:day];
        } else{
            [dateComponents setDay:[myCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate].length];
            day=[myCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate].length;
        }
        Cdate=newDate;
        [datePicker reloadAllComponents];
        [datePicker selectRow:day-1 inComponent:0 animated:FALSE];
        [datePicker selectRow:month-1 inComponent:1 animated:FALSE];
        [datePicker selectRow:row inComponent:2 animated:FALSE];
        
        
    }
    [self setRecur:recurrence];
    
    
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (component==0) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:Cdate];
        
        [dateComponents setDay:row+1];
        NSDate *newDate = [calendar dateFromComponents:dateComponents];
        NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
        //[myFormatter stringFromDate:Cdate]
        [myFormatter setDateFormat:@"eee dd"];
        return [myFormatter stringFromDate:newDate];
        
    }
    else if (component==1){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:Cdate];
        [dateComponents setDay:1];
        [dateComponents setMonth:row+1];
        NSDate *newDate = [calendar dateFromComponents:dateComponents];
        NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
        //[myFormatter stringFromDate:Cdate]
        [myFormatter setDateFormat:@"MMM"];
        return [myFormatter stringFromDate:newDate];
    }
    return [NSString stringWithFormat:@"%d", row+1];
}

//More DBstuff -Ahmed
- (void)deleteExistingTaskInDatabaseWithName:(NSString*)theName withFolder:(NSString *)theFolder {
    const char *filePath = [databasePath UTF8String];
    
    sqlite3_stmt *statement;
	
	if(sqlite3_open(filePath, &atmaDB) == SQLITE_OK)
    {
        progress = [[self retrieveValue:@"current" FromTask:theName FromFolder:folderName] integerValue];
        NSString *querySQL = [NSString stringWithFormat:@"select priority from tasks where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [theFolder UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            NSString *priorityRaw = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(statement, 0)];
            taskPriority = [priorityRaw intValue];
            sqlite3_finalize(statement);
        }
		NSString *insertSQL = [NSString stringWithFormat:@"delete from tasks where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [theFolder UTF8String]];
        [self executeSQL:insertSQL];
		sqlite3_finalize(statement);
        sqlite3_close(atmaDB);
        
	}

}

- (Boolean)checkUniquenessForTaskInDatabaseWithName:(NSString*)theName withFolder:(NSString *)theFolder {
    Boolean toReturn = FALSE;
    const char *filePath = [databasePath UTF8String];
    
    sqlite3_stmt *statement;
    
    if(sqlite3_open(filePath, &atmaDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"select * from tasks where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [theFolder UTF8String]];
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(atmaDB, insert_stmt, -1, &statement, NULL);
        
        sqlite3_step(statement);
        
        if(sqlite3_data_count(statement) == 0 ) {
            toReturn = TRUE;
        } else {
            toReturn = FALSE;
        }
        sqlite3_finalize(statement);
        sqlite3_close(atmaDB);
    }
    return toReturn;
}

- (void)saveTaskInDatabaseWithName:(NSString *)theName withUnits:(NSString *)theUnits withFolder:(NSString *)theFolder withPeriod:(int)thePeriod withDate:(double)theDate withTarget:(NSInteger *)theTarget  {
	
    
	const char *filePath = [databasePath UTF8String];
    
    sqlite3_stmt *statement;
	
	if(sqlite3_open(filePath, &atmaDB) == SQLITE_OK)
    {
        NSString* b, *countStr;
        int a = 0, count = 0;
        if (editingTask) {
            a = taskPriority;
        } else {
            NSString* querySQL = [NSString stringWithFormat:@"select count(*) from tasks where folder = \"%s\";", [theFolder UTF8String]];
            const char *query_stmt = [querySQL UTF8String];
            if (sqlite3_prepare_v2(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    countStr = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    count = [countStr integerValue];
                } else {
                }
                sqlite3_finalize(statement);
            }
            if (count > 0)
            {
                querySQL = [NSString stringWithFormat:@"select max(priority) from tasks where folder = \"%s\";", [theFolder UTF8String]];
                query_stmt = [querySQL UTF8String];
                if (sqlite3_prepare_v2(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    if (sqlite3_step(statement) == SQLITE_ROW)
                    {
                        b = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                        a = [b integerValue];
                    } else {
                    }
                    sqlite3_finalize(statement);
                }
            }
            a++;
        }
		NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO tasks (name, units, folder, period, enddate, current, target, priority) values (\"%@\", \"%@\", \"%@\", %d, %f, %d, %d, %d)", theName, theUnits, theFolder, thePeriod, theDate, progress, (int)theTarget, a];
        const char *insert_stmt = [insertSQL UTF8String];
        
		sqlite3_prepare_v2(atmaDB, insert_stmt, -1, &statement, NULL);
        
        if(sqlite3_step(statement) == SQLITE_DONE ) {
			status.text = @"Contact added";
            //printf("Added task.\n");
		} else {
            //fail state
        }
		sqlite3_finalize(statement);
        sqlite3_close(atmaDB);
	}
}

- (NSString*) retrieveValue:(NSString*) theValue FromTask:(NSString*) theName FromFolder:(NSString*)theFolder
{
    NSString *querySQL = [NSString stringWithFormat:@"select %s from tasks where name = \"%s\" and folder = \"%s\";", [theValue UTF8String], [theName UTF8String], [theFolder UTF8String]];
    return [[[self executeSQL:querySQL ReturningRows:1] objectAtIndex:0] objectAtIndex:0];
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
    int j = 0;
    int i  = 0;
    
    allRows = [[NSMutableArray alloc] init];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        const char *query_stmt = [theStatement UTF8String];
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                for (i  = 0; i < numRows; i++)
                {
                    stringArray[i] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i)];
                }
                
                row = [NSArray arrayWithObjects:stringArray count:numRows];
                [allRows addObject:row];
                j++;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
    
    return allRows;
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

@end;

///////MITCH CODE END