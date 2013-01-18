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
    //Database call
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
    NSDate *today = datePicker.date;
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"EEEE"]; // day, like "Saturday"
    
    NSString *dayOfWeek = [myFormatter stringFromDate:today];
    lblDate.text =dayOfWeek;

}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSDate *now = [NSDate date];
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
    
    if (component == 0) {
        return [myCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:now].length;
    }
    else if (component==1){
        return [myCalendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:now].length;
    }
    return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d", row+1];
}


@end;

///////MITCH CODE END