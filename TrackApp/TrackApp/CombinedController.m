//
//  CombinedController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 3/20/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "CombinedController.h"
#import "AppDelegate.h"
#import "TaskDetailViewController.h"

@implementation CombinedController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //BELOW THIS LINE IS UNIQUE
    self.navigationItem.leftBarButtonItem = setupButton;
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:path];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navDetailVC = [self.splitViewController.viewControllers objectAtIndex:1];
    TaskDetailViewController *detailVC = navDetailVC.visibleViewController;
    
    detailVC.navigationItem.title = [self.folderNames objectAtIndex: [indexPath row]];
    [detailVC updateTaskTable:[self.folderNames objectAtIndex: [indexPath row]]];
}


@end
