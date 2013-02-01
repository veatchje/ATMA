//
//  TaskTableViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TaskTableViewCell.h"

@interface TaskTableViewController : UITableViewController{
    UIBarButtonItem *resetTasksButton;
    NSString* folderName;
    UILabel *status;
    NSString *databasePath;
    sqlite3 *atmaDB;  
}


#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

@property (nonatomic, strong) NSMutableArray *taskNames;
@property (nonatomic, strong) NSMutableArray *visibleBools;
//AHMED CODE START
@property (nonatomic, strong) NSMutableArray *taskTotals;
@property (nonatomic, strong) NSMutableArray *taskPeriods;
@property (nonatomic, strong) NSMutableArray *taskEndDates;
@property (nonatomic, strong) NSMutableArray *taskCurrents;
@property (nonatomic, strong) NSMutableArray *taskTargets;
@property (retain, nonatomic) IBOutlet UILabel *status;
//AHMED CODE END

@end

///////MITCH'S CODE END
