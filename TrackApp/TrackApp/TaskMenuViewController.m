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

@interface SetupTableViewController ()

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end;

@implementation SetupTableViewController{
    NSArray *tableData;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    tableData = [NSArray arrayWithObjects:@"Folders", @"Settings", @"About", nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *setupTableIdentifier = @"SetupTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:setupTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:setupTableIdentifier];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    return cell;
}

@end
