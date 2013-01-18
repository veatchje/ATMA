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

@interface TaskTableViewController : UITableViewController{
    UIBarButtonItem *newTaskButton;
    NSString* folderName;
}

#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

@property (nonatomic, strong) NSMutableArray *taskNames;
//AHMED CODE START
@property (nonatomic, strong) NSMutableArray *taskUnits;
@property (nonatomic, strong) NSMutableArray *taskPeriods;
@property (nonatomic, strong) NSMutableArray *taskEndDates;
@property (nonatomic, strong) NSMutableArray *taskCurrents;
@property (nonatomic, strong) NSMutableArray *taskTargets;
//AHMED CODE END

@end

///////MITCH'S CODE END
