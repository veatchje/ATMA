//
//  CreateTaskViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 11/30/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH'S CODE START

#import <UIKit/UIKit.h>

@interface CreateTaskViewController : UIViewController {
    IBOutlet UIScrollView *scrollview;
    IBOutlet UIDatePicker* datePicker;
    IBOutlet UILabel* lblDate;
}
- (IBAction)openSetupMenu;
- (IBAction)cancel;
- (IBAction)save;

@end

///////MITCH'S CODE END
