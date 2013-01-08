//
//  TaskTableViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH'S CODE START

#import <UIKit/UIKit.h>

@interface TaskTableViewController : UITableViewController{
    UIBarButtonItem *newTaskButton;
}

@property (nonatomic, strong) NSMutableArray *taskNames;

@end

///////MITCH'S CODE END
