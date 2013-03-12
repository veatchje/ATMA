//
//  TaskTableViewCell.h
//  TrackApp
//
//  Created by Stewart, Mitchell J on 12/18/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

///////MITCH CODE START

#import <UIKit/UIKit.h>

@interface TaskTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *taskName;
@property (nonatomic, strong) NSNumber *taskTotal;
@property (nonatomic, strong) IBOutlet UIButton *plusButton;
@property (nonatomic, strong) IBOutlet UIButton *cellButton;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progress;
@property (nonatomic, strong) IBOutlet UILabel *progressText;
@end

///////MITCH CODE END
