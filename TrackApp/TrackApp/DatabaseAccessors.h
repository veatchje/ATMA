//
//  DatabaseAccessors.h
//  TrackApp
//
//  Created by Al-Shaali, Ahmed on 5/4/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseAccessors : NSObject {
    NSString *databasePath;
    sqlite3 *atmaDB;
}

#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

- (NSMutableArray*) loadNamesFromDatabase;
- (void) initializeDatabase;
- (void)saveNameInDatabase:(NSString *)theName;
- (void) deleteFolder:(NSString *) theName;


@end
