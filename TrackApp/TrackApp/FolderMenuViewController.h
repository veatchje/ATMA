//
//  FolderMenuViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetupTableViewController.h"

@interface FolderMenuViewController : UIViewController {
    IBOutlet UIScrollView *scrollview;
}
- (IBAction)openEditDialog;
- (IBAction)openSetupMenu;
- (IBAction)switchToTaskScreen;
- (IBAction)alert;

@end
