//
//  TaskDetailViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 3/20/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "AppDelegate.h"
#import "CombinedController.h"

@implementation TaskDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = folderButton;

}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Folders";
    folderButton = barButtonItem;
    self.navigationItem.leftBarButtonItem = folderButton;
    
    
    masterPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
    self.navigationItem.leftBarButtonItem = nil;
    
    masterPopoverController = nil;
}


- (void) updateTaskTable:(NSString *) folder
{
    [self viewDidLoad];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:animate];
    if(editing){
        self.navigationItem.leftBarButtonItem = resetTasksButton;
        int count =visibleBools.count;
        [visibleBools removeAllObjects];
        for(int i = 0;i<count-1;i++){
            [visibleBools addObject:@"true"];
        }
        
        [self.tableView reloadData];
    }
    else{
        self.navigationItem.leftBarButtonItem = folderButton;
        int count =visibleBools.count;
        [visibleBools removeAllObjects];
        for(int i = 0;i<count-1;i++){
            [visibleBools addObject:@"false"];
        }
        [self.tableView reloadData];
    }
}

@end
