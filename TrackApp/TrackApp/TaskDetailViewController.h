//
//  TaskDetailViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 3/20/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "Tasks.h"

@interface TaskDetailViewController : Tasks<UISplitViewControllerDelegate>
{
    UIPopoverController *masterPopoverController;
    UIBarButtonItem* folderButton;
}

@property (nonatomic,strong) IBOutlet UIToolbar *toolbar;

-(void) updateTaskTable: (NSString *) folder;

@end
