//
//  CreateTaskViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH'S CODE START

#import "CreateTaskViewController.h"

@interface CreateTaskViewController ()

@end

@implementation CreateTaskViewController
- (IBAction)openSetupMenu {
    //put code here
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
    
    NSDate* dt = datePicker.date;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
   // NSCalendar *calendar = [NSCalendar currentCalendar];
   // NSInteger units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
    //NSDateComponents *components = [calendar components:units fromDate:dt];
   // NSInteger year = [components year];
   // NSInteger day = [components day];
    
    NSDateFormatter *weekDay = [[NSDateFormatter alloc] init];
    [weekDay setDateFormat:@"EEEE"];
    
    NSDateFormatter *calMonth = [[NSDateFormatter alloc] init];
    [calMonth setDateFormat:@"MM"];
    
    lblDate.text = [weekDay stringFromDate:dt];}

@end;

///////MITCH'S CODE END