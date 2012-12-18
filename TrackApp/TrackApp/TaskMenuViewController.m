//
//  TaskMenuViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import "TaskMenuViewController.h"

@interface TaskMenuViewController ()

@end

@implementation TaskMenuViewController
- (IBAction)openEditDialog {
    //put code here
}

- (IBAction)openSetupMenu {
    //put code here
}

- (IBAction)openEditTaskView {
    /*GameMenuController *gmc = [[GameMenuController alloc] initWithNibName:@"GameMenuController" bundle:nil];
     [self.navigationController pushViewController:gmc animated:NO];*/
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [scrollview setScrollEnabled:YES];
    [scrollview setContentSize:CGSizeMake(320, 800)];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end;

