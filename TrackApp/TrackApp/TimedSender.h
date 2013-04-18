//
//  TimedSender.h
//  TrackApp
//
//  Created by Collins, Brian C on 4/17/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

//Brian's code start

#import <Foundation/Foundation.h>
#import "FileIoAppDelegate.h";

@interface TimedSender : NSObject {
    FileIoAppDelegate *sender;
    NSTimer *timer;
}

- (TimedSender *) constructWithSender:(FileIoAppDelegate *)
        ioSender interval:(double) interval startDate:(NSDate *) date;

@end

//Brian's code end
