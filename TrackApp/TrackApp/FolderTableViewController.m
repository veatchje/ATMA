//
//  FolderTableViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH'S CODE START

#import "FolderTableViewController.h"
#import "FolderTableViewCell.h"
#import "TaskMenuViewController.h"

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

- (IBAction)setupAlert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Main Menu" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"About", @"Settings", @"Help", nil];
    
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showFolderTitle"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TaskMenuViewController *destViewController = segue.destinationViewController;
        destViewController.navigationItem.title = [self.folderNames objectAtIndex:indexPath.row];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *img = [UIImage imageNamed:@"folder.png"];
    [self.folderImage setImage:img];
    
    self.folderNames = [[NSMutableArray alloc]
                        initWithObjects:@"Business",
                        @"Personal", nil];
    
    //ETHAN'S LINE OF CODE
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    newFolderButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                    target:self
                                                                    action:@selector(alert)];
    
    setupButton = [[UIBarButtonItem alloc] initWithTitle:@"Setup" style:UIBarButtonItemStylePlain target:self
                                                                action:@selector(setupAlert)];
    
}

//////START BRIAN'S CODE

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

//////END BRIAN'S CODE

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

//Edit and Delete
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.folderNames removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:animate];
    if(editing)
        self.navigationItem.leftBarButtonItem = newFolderButton;
    else
        self.navigationItem.leftBarButtonItem = setupButton;
    
}

@end

///////MITCH'S CODE END
