//
//  Tasks.h
//  TrackApp
//
//  Created by Veatch, James E on 5/8/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TaskTableViewCell.h"
#import "DatabaseAccessors.h"
#import "CreateTaskViewController.h"

@interface Tasks : UITableViewController {
    UIBarButtonItem *resetTasksButton;
    NSString* folderName;
    UILabel *status;
    NSString* selectedTaskName;

    UITextField *taskNumberTextField;
    UIAlertView *taskAlertView;
    NSInteger *plusButtonIndex;
    NSInteger *cellIndex;
    
    NSMutableArray *taskNames;
    NSMutableArray *visibleBools;
    NSMutableArray *taskTotals;
    NSMutableArray *taskPeriods;
    NSMutableArray *taskUnits;
    NSMutableArray *taskEndDates;
    NSMutableArray *taskCurrents;
    NSMutableArray *taskTargets;
    
}

#define TAG_INCREMENT 1
#define TAG_RESET_ALL 2
#define TAG_TASK_CHANGE 3

@end
