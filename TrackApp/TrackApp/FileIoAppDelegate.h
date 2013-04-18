//
//  FileIoAppDelegate.h
//  TrackApp
//
//  Created by Collins, Brian C on 3/22/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

//Brian's code start

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface FileIoAppDelegate : NSObject <UIApplicationDelegate> {
    NSString *databasePath;
    sqlite3 *atmaDB;
    
    NSString *folderToCollectFrom;
    NSString *emailToSendTo;
}

- (FileIoAppDelegate *) constructWithFolderName:(NSString *) folderName Email:(NSString *) email;
- (void) collectAndSendData;

@end

//Brian's code end
