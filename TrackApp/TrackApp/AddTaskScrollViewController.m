//
//  AddTaskScrollViewController.m
//  TrackApp
//
//  Created by Veatch, James E on 12/9/12.
//  Copyright (c) 2012 ATMA. All rights reserved.
//

#import "AddTaskScrollViewController.h"

@implementation AddTaskScrollViewController

@synthesize scrollView;

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
    scrollView.frame = CGRectMake(0,0,320,460);
    
    [scrollView setContentSize:CGSizeMake(320,656)];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
