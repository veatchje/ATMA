//
//  FolderTableViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import "FolderTableViewController.h"
#import "FolderTableViewCell.h"

@implementation FolderTableViewController
@synthesize folderImage = _folderImage;
@synthesize folderNames = _folderNames;

- (IBAction)alert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Folder" message:@"Put in folder name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    UITextField *folderNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
    [folderNameTextField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:folderNameTextField];
    
    
    NSString *folderName = folderNameTextField.text;
    
    [alert show];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *img = [UIImage imageNamed:@"folder.png"];
    [self.folderImage setImage:img];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"folderTableCell";
    
    FolderTableViewCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FolderTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.folderName.text = [self.folderNames
                           objectAtIndex: [indexPath row]];
    
        
    return cell;
}

@end
