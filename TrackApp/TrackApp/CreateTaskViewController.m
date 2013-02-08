//
//  CreateTaskViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import "CreateTaskViewController.h"

@interface CreateTaskViewController ()

@end

@implementation CreateTaskViewController
- (IBAction)openSetupMenu {
    //put code here
}

- (void) setFolderName: (NSString*) name {
    folderName = name;
}

- (IBAction)cancel {
    //Clear fields
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save {
    
    //Date is integer???
    
    //The idea here is to save it to the DB then load it once back at the Tasks screen
    [self saveTaskInDatabaseWithName:taskName.text withUnits:unitName.text withFolder:folderName withPeriod:[self calculatePeriod] withDate:Cdate.timeIntervalSince1970 withTarget:[goalNumber.text intValue]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //scrollView.frame = CGRectMMake(0,0.320.460);
    [scrollview setScrollEnabled:YES];
    [scrollview setContentSize:CGSizeMake(320, 900)];
    Cdate=[NSDate date];
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    //[myFormatter stringFromDate:Cdate]
    [myFormatter setDateFormat:@"dd"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1  inComponent:0 animated:FALSE];
    [myFormatter setDateFormat:@"MM"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1 inComponent:1  animated:FALSE];
    [myFormatter setDateFormat:@"yyyy"];
    [datePicker selectRow:[[myFormatter stringFromDate:Cdate] intValue]-1 inComponent:2 animated:FALSE];

    
    
    
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
     //The DB stuff ends here
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

- (int) calculatePeriod{
    int period = recurrence.selectedSegmentIndex;
    switch (period) {
        case 0:
            return 1;
            break;
        case 1:
            return 7;
            break;
        case 2:
            //Need to fix datePicker here
            //            int day = [datePicker selectedRowInComponent:0];
            //            period = day*(-1);
            return 30;
        case 3:
            //custom
        default:
            return 0;
            break;
    }
}

//More DBstuff -Ahmed
- (void)saveTaskInDatabaseWithName:(NSString *)theName withUnits:(NSString *)theUnits withFolder:(NSString *)theFolder withPeriod:(NSInteger *)thePeriod withDate:(double)theDate withTarget:(NSInteger *)theTarget  {
	
	const char *filePath = [databasePath UTF8String];
    
    sqlite3_stmt *statement;
	
	if(sqlite3_open(filePath, &atmaDB) == SQLITE_OK)
    {
        //This may cause issues with deletion; nonunique priorities. Can change to just highest priority+1.
        int a = 0;
        sqlite3_exec(atmaDB, "select max(priority) from tasks", NULL, (int*)a, NULL);
        a++;
		NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO CONTACTS (name, units, folder, period, enddate, current, target, priority) values (\"%@\", \"%@\", \"%@\", %@, %f, %d, %@, %d)", theName, theUnits, theFolder, thePeriod, theDate, 0, theTarget, a];
        const char *insert_stmt = [insertSQL UTF8String];
        
		//sqlite3_stmt *compiledStatement;
		sqlite3_prepare_v2(atmaDB, insert_stmt, -1, &statement, NULL);
        
        if(sqlite3_step(statement) == SQLITE_DONE ) {
			status.text = @"Contact added";
		} else {
            //fail state
        }
		sqlite3_finalize(statement);
        sqlite3_close(atmaDB);
	}
}


@end;

///////MITCH CODE END