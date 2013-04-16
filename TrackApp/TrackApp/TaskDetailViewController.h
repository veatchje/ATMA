//
//  TaskDetailViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 3/20/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TaskTableViewCell.h"

@interface TaskDetailViewController : UITableViewController<UISplitViewControllerDelegate>
{
    UIPopoverController *masterPopoverController;
    
    UIBarButtonItem *resetTasksButton;
    NSString* folderName;
    UILabel *status;
    NSString *databasePath;
    sqlite3 *atmaDB;
    NSString* selectedTaskName;
    
    UITextField *taskNumberTextField;
    UIAlertView *taskAlertView;
    NSInteger *plusButtonIndex;
    NSInteger *cellIndex;
}


#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

@property (nonatomic,strong) IBOutlet UIToolbar *toolbar;

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

-(void) updateTaskTable: (NSString *) folder;

@end
