//
//  ScrollTestViewController.m
//  TrackApp
//
//  Created by Collins, Brian C on 12/11/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import "ScrollTestViewController.h"

@interface ScrollTestViewController ()

@end

@implementation ScrollTestViewController

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
    
    [Scroller setScrollEnabled:YES];
    [Scroller setContentSize:CGSizeMake(320, 1000)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
