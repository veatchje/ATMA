//
//  FolderMenuViewController.m
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import "FolderMenuViewController.h"
#import "TaskMenuViewController.h"

@interface FolderMenuViewController ()

@end

@implementation FolderMenuViewController

- (IBAction)alert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Folder" message:@"Put in folder name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    UITextField *folderNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
    [folderNameTextField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:folderNameTextField];
    
    
    NSString *folderName = folderNameTextField.text;
    
    [alert show];
}

- (IBAction)openEditDialog {
    //put code here
}

- (IBAction)openSetupMenu {
    //put code here
}

- (IBAction)switchToTaskScreen {
    TaskMenuViewController *tmvc = [[TaskMenuViewController alloc] initWithNibName:@"TaskMenuViewController" bundle:nil];
    [self.navigationController pushViewController:tmvc animated:NO];
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

@end
