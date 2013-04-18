//
//  TimedSender.m
//  TrackApp
//
//  Created by Collins, Brian C on 4/17/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

//Brian's code start

#import "TimedSender.h"

@implementation TimedSender

// A constructor for ease of use.
- (TimedSender *) constructWithSender:(FileIoAppDelegate *)
        ioSender interval:(double) interval startDate:(NSDate *) date
{
    return [[TimedSender alloc] initWithSender:ioSender interval:interval startDate:date];
}

- (TimedSender *) initWithSender:(FileIoAppDelegate *)
        ioSender interval:(double) interval startDate:(NSDate *) date
{
    self = [super init];
    
    if (self)
    {
        sender = ioSender;
        // TODO: make sure this is how timers are supposed to work
        timer = [self timerWithInterval:interval startDate:date];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    
    return self;
}

- (NSTimer *) timerWithInterval:(double) interval startDate:(NSDate *) date
{
    return [[NSTimer alloc] initWithFireDate:date
                            interval:interval
                            target:self
                            selector:@selector(send)
                            userInfo:nil
                            repeats:YES];
}

- (void) send
{
    [sender collectAndSendData];
}

@end

//Brian's code end
