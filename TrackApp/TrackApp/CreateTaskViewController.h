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
    Boolean editExistingTask;
    
    IBOutlet UIScrollView *scrollview;
    IBOutlet UIPickerView* datePicker;
    IBOutlet UILabel* lblDate;
    
    IBOutlet UITextField* taskName;
    IBOutlet UITextField* unitName;
    IBOutlet UITextField* goalNumber;
    //Ethan's code
    IBOutlet UISegmentedControl* recurrence;
    NSDate *Cdate;
    
    //Ahmed's code
    UILabel *status;
    NSString *databasePath;
    sqlite3 *atmaDB;
    
    NSString* folderName;
}


#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"


@property (retain, nonatomic) IBOutlet UILabel *status;
@property (nonatomic, retain) UITextField *taskName;
//Ahmed's code ends here
- (void)setFolderName: (NSString*) name;
- (void)populateFields: (NSString*) currentTaskName;
- (IBAction)openSetupMenu;
- (IBAction)cancel;
- (IBAction)save;

///////MITCH CODE END
//Brian's code
- (void) setEditExistingTask: (Boolean) eet;
- (void) setTaskName: (NSString*) name;
- (void) setUnitName: (NSString*) name;
//- (void) setGoalNumber: (int) num;
- (void) setCdate: (double) time;
//TODO: setRecurrence

@end