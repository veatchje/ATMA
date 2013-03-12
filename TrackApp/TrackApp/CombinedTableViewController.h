//
//  CombinedTableViewController.h
//  TrackApp
//
//  Created by Collins, Brian C on 1/22/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

//BRIAN CODE START

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TaskTableViewCell.h"
#import "FolderCollectionViewCell.h"
#import "CreateTaskViewController.h"

@interface CombinedTableViewController : UITableViewController<UICollectionViewDataSource, UICollectionViewDelegate>{
    // Folder screen portion
	IBOutlet UITextView *textView;
	IBOutlet UITextField *textField;
	
	NSMutableArray *_namesArray;
    
    UIBarButtonItem *newFolderButton;
    UIBarButtonItem *setupButton;
    
    UITextField *folderNameTextField;
    
    IBOutlet UICollectionView *folderCollectionView;
    
    Boolean isShowingLandscapeView;
    
    // Task screen portion
    UIBarButtonItem *resetTasksButton;
    NSString* folderName;
    UILabel *status;
    NSString *databasePath;
    sqlite3 *atmaDB;
    
    UITextField *taskNumberTextField;
    UIAlertView *taskAlertView;
}


#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

@property (nonatomic, strong) UIImageView *folderImage;
@property (nonatomic, strong) NSMutableArray *folderNames;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITextField *textField;

- (IBAction)alert;
- (IBAction)sendTitle:(id)sender;
- (void) loadNamesFromDatabase;

@property (nonatomic, strong) NSMutableArray *taskNames;
@property (nonatomic, strong) NSMutableArray *visibleBools;
//AHMED CODE START
@property (nonatomic, strong) NSMutableArray *taskTotals;
//The number of days allowed for the task
@property (nonatomic, strong) NSMutableArray *taskPeriods;
//The units the task is measured in
@property (nonatomic, strong) NSMutableArray *taskUnits;
//The date the task is due
@property (nonatomic, strong) NSMutableArray *taskEndDates;
//The current progress of the task
@property (nonatomic, strong) NSMutableArray *taskCurrents;
//The target goal of progress for the task
@property (nonatomic, strong) NSMutableArray *taskTargets;
@property (retain, nonatomic) IBOutlet UILabel *status;
//AHMED CODE END

//@property (nonatomic, assign) id <UICollectionViewDelegate> delegate;
//@property (nonatomic) BOOL allowsSelection;

@end

//BRIAN CODE END