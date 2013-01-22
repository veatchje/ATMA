//
//  CreateTaskViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#pragma mark -
#pragma mark PickerView DataSorce

@interface CreateTaskViewController : UIViewController {
    IBOutlet UIScrollView *scrollview;
    IBOutlet UIDatePicker* datePicker;
    IBOutlet UILabel* lblDate;
    
    IBOutlet UITextField* taskName;
    IBOutlet UITextField* unitName;
    IBOutlet UITextField* goalNumber;
    
    //Ahmed's code
    UILabel *status;
    NSString *databasePath;
    sqlite3 *atmaDB;
    
    NSString* folderName;
}


#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"


@property (retain, nonatomic) IBOutlet UILabel *status;
//Ahmed's code ends here
- (void)setFolderName: (NSString*) name;
- (IBAction)openSetupMenu;
- (IBAction)cancel;
- (IBAction)save;

@end

///////MITCH CODE END
