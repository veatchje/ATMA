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
            NSArray* r = [DatabaseAccessors deleteExistingTaskInDatabaseWithName:origTaskName withFolder:folderName];
            progress = [[r objectAtIndex:0] integerValue];
            taskPriority = [[r objectAtIndex:1] integerValue];
        } else {
            progress = 0;
            taskPriority = -1;
        }
        if ([DatabaseAccessors checkUniquenessForTaskInDatabaseWithName:origTaskName withFolder:folderName])
        {
            [DatabaseAccessors saveTaskInDatabaseWithName:taskName.text withUnits:unitName.text withFolder:folderName withPeriod:selectedRecur withDate:Cdate.timeIntervalSince1970 withTarget:[goalNumber.text intValue] withProgress:progress withPriority:taskPriority];
            
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
    [DatabaseAccessors initializeDatabase];
    
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

@end;

///////MITCH CODE END