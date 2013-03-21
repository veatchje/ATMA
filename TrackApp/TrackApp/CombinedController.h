//
//  CombinedController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 3/20/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface CombinedController : UITableViewController {
    
    IBOutlet UITextView *textView;
	IBOutlet UITextField *textField;
    NSString *databasePath;
    sqlite3 *atmaDB;
    
	
	NSMutableArray *_namesArray;
    
    UIBarButtonItem *setupButton;
    
    UITextField *folderNameTextField;
}

#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

@property (nonatomic, strong) UIImageView *folderImage;
@property (nonatomic, strong) NSMutableArray *folderNames;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITextField *textField;

- (IBAction)sendTitle:(id)sender;
- (void) loadNamesFromDatabase;
- (void) newTaskButtonTouched;

@end
