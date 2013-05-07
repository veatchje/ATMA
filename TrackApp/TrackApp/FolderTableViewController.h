//
//  FolderTableViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DatabaseAccessors.h"

@interface FolderTableViewController : UITableViewController {
    
	// Outlets
	IBOutlet UITextView *textView;
	IBOutlet UITextField *textField;
    NSString *databasePath;
    sqlite3 *atmaDB;

	DatabaseAccessors *dbAccess;
	NSMutableArray *_namesArray;
    
    UIBarButtonItem *setupButton;
    
    UITextField *folderNameTextField;
}

//#define DATABASE_NAME @"atmadatabase.db"
//#define DATABASE_TITLE @"atmadatabase"

@property (nonatomic, strong) UIImageView *folderImage;
@property (nonatomic, strong) NSMutableArray *folderNames;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITextField *textField;

- (IBAction)sendTitle:(id)sender;
//- (void) loadNamesFromDatabase;

///////BRIAN'S CODE START

- (BOOL)shouldAutorotate;
- (NSInteger)supportedInterfaceOrientations;

///////BRIAN'S CODE END

@end

///////MITCH CODE END
