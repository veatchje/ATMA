//
//  FolderTableViewController.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH'S CODE START

#import <UIKit/UIKit.h>

@interface FolderTableViewController : UITableViewController

@property (nonatomic, strong) UIImageView *folderImage;
@property (nonatomic, strong) NSArray *folderNames;

- (IBAction)alert;

@end

///////MITCH'S CODE END
