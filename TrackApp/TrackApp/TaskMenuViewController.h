//
//  TaskMenuViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskMenuViewController : UIViewController {
    
}
- (IBAction)openEditDialog;
- (IBAction)openSetupMenu;
- (IBAction)openEditTaskView;

@end

@interface SetupTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@end