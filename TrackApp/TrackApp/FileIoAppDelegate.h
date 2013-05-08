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

@interface FileIoAppDelegate : NSObject <UIApplicationDelegate> { //UIViewController <MFMailComposeViewControllerDelegate> {
    NSString *databasePath;
    sqlite3 *atmaDB;
    
    NSString *folderToCollectFrom;
    NSString *emailToSendTo;
}

//Ahmed's defines
#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

+ (FileIoAppDelegate *) constructWithFolderName:(NSString *) folderName;
- (void) setFolder:(NSString *) folder;
- (NSString*) writeFolderToFile;
- (NSString*) stringFromDatabase;
//- (void) setEmail:(NSString *) email;

// For testing
- (NSString *) stringFromDatabase:(NSString *) theFolderName;
- (NSString *) writeFolderToFile:(NSString *) theFolderName;

@end

//Brian's code end
