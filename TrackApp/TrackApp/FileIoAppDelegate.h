//
//  FileIoAppDelegate.h
//  TrackApp
//
//  Created by Collins, Brian C on 3/22/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface FileIoAppDelegate : NSObject <UIApplicationDelegate> {
    NSString *databasePath;
    sqlite3 *atmaDB;
}

@end
