//
//  FolderTableViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import "FolderTableViewController.h"
#import "FolderTablewViewCell.h"

@implementation FolderTableViewController
@synthesize folderImage = _folderImage;
@synthesize folderNames = _folderNames;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.folderImage = @"folder.jpg";
    
    self.folderNames = [[NSArray alloc]
                        initWithObjects:@"Business",
                        @"Personal", nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.folderNames count];
}

@end
