//
//  TaskMenuViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//


///////MITCH'S CODE START

#import <UIKit/UIKit.h>
#import "SetupTableViewController.h"

@interface TaskMenuViewController : UIViewController {
    IBOutlet UIScrollView *scrollview;
}
- (IBAction)openEditDialog;
- (IBAction)openSetupMenu;
- (IBAction)openEditTaskView;

@end

///////MITCH'S CODE END
