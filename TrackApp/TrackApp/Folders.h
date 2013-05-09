//
//  Folders.h
//  TrackApp
//
//  Created by Veatch, James E on 5/8/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DatabaseAccessors.h"
#import "FolderTableViewCell.h"
#import "HelpDocController.h"
#import "MessageUI/MessageUI.h"
#import "FileIoAppDelegate.h"

@interface Folders : UITableViewController {
    
	IBOutlet UITextView *textView;
	IBOutlet UITextField *textField;
    NSString *databasePath;
    sqlite3 *atmaDB;
    
	NSMutableArray *_namesArray;
    
    UIBarButtonItem *setupButton;
    
    UITextField *folderNameTextField;
}

@property (nonatomic, strong) UIImageView *folderImage;
@property (nonatomic, strong) NSMutableArray *folderNames;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITextField *textField;

#define TAG_SETUP 1
#define TAG_NEWFOLDER 2

- (IBAction)setupAlert;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void) insertAddRowIntoArray;

@end
