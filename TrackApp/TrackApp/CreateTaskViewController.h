//
//  CreateTaskViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#pragma mark -
#pragma mark PickerView DataSorce

@interface CreateTaskViewController : UIViewController {
    //Brian's line of code
    Boolean editingTask;
    
    IBOutlet UIScrollView *scrollview;
    IBOutlet UIPickerView* datePicker;
    IBOutlet UILabel* lblDate;
    
    IBOutlet UITextField* taskName;
    IBOutlet UITextField* unitName;
    IBOutlet UITextField* goalNumber;
    //Ethan's code
    IBOutlet UISegmentedControl* recurrence;
    NSDate *Cdate;
    int selectedRecur;
    UIAlertView* recurAlert;
    UITextField* customRecurTextField;
    
    //Ahmed's code
    UILabel *status;
    NSString *databasePath;
    sqlite3 *atmaDB;
    NSString* origTaskName;
    NSString* folderName;
    int taskPriority;
    int progress;
    
}


#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"


@property (retain, nonatomic) IBOutlet UILabel *status;
//@property (nonatomic, retain) UITextField *taskName;
//Ahmed's code ends here
- (void)setFolderName: (NSString*) name;
- (void)populateFields: (NSString*) currentTaskName WithUnits:(NSString*) currentUnits WithGoal:(NSString*) currentGoal WithRecurrance:(int) currentDays EndingOn:(double)currentEnd;
- (IBAction)cancel;
- (IBAction)save;

///////MITCH CODE END
//Brian's code
- (void) setEditingTask: (Boolean) editing;
//- (void) setTaskName: (NSString*) name;
//- (void) setUnitName: (NSString*) name;
////- (void) setGoalNumber: (int) num;
//- (void) setCdate: (double) time;
//TODO: setRecurrence

@end