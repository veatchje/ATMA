//
//  CreateTaskViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import <UIKit/UIKit.h>
#pragma mark -
#pragma mark PickerView DataSorce

@interface CreateTaskViewController : UIViewController {
    IBOutlet UIScrollView *scrollview;
    IBOutlet UIDatePicker* datePicker;
    IBOutlet UILabel* lblDate;
    
    IBOutlet UITextField* taskName;
    IBOutlet UITextField* unitName;
    IBOutlet UITextField* goalNumber;
    
    NSString* folderName;
}
- (void)setFolderName: (NSString*) name;
- (IBAction)openSetupMenu;
- (IBAction)cancel;
- (IBAction)save;

@end

///////MITCH CODE END
