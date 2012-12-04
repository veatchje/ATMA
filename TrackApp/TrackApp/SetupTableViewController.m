//
//  SetupTableViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/4/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import "SetupTableViewController.h"


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
