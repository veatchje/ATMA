//
//  CombinedTableViewController.h
//  TrackApp
//
//  Created by Collins, Brian C on 1/22/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

//BRIAN CODE START

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TaskTableViewCell.h"
#import "FolderCollectionViewCell.h"
#import "CreateTaskViewController.h"

@interface CombinedTableViewController : UITableViewController<UICollectionViewDataSource, UICollectionViewDelegate>{
    // Folder screen portion
	IBOutlet UITextView *textView;
	IBOutlet UITextField *textField;
	
	NSMutableArray *_namesArray;
    
    UIBarButtonItem *newFolderButton;
    UIBarButtonItem *setupButton;
    
    UITextField *folderNameTextField;
    
    IBOutlet UICollectionView *folderCollectionView;
    
    // Task screen portion
    UIBarButtonItem *newTaskButton;
    NSString* folderName;
    UILabel *status;
    NSString *databasePath;
    sqlite3 *atmaDB;
}


#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

@property (nonatomic, strong) UIImageView *folderImage;
@property (nonatomic, strong) NSMutableArray *folderNames;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITextField *textField;

- (IBAction)alert;
- (IBAction)sendTitle:(id)sender;
- (void) loadNamesFromDatabase;

@property (nonatomic, strong) NSMutableArray *taskNames;
//AHMED CODE START
@property (nonatomic, strong) NSMutableArray *taskUnits;
@property (nonatomic, strong) NSMutableArray *taskPeriods;
@property (nonatomic, strong) NSMutableArray *taskEndDates;
@property (nonatomic, strong) NSMutableArray *taskCurrents;
@property (nonatomic, strong) NSMutableArray *taskTargets;
@property (retain, nonatomic) IBOutlet UILabel *status;
//AHMED CODE END

@end

//BRIAN CODE END