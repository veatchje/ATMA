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
}

#define DATABASE_NAME @"atmadatabase.db"
#define DATABASE_TITLE @"atmadatabase"

+ (NSMutableArray*) loadNamesFromDatabase;
+ (void) initializeDatabase;
+ (void)saveNameInDatabase:(NSString *)theName;
+ (void) deleteFolder:(NSString *) theName;
+ (NSMutableArray*)loadTasksFromDatabaseForFolder:(NSString*)theFolder;
+ (void)incrementTaskWithName:(NSString*)theName FromFolder:(NSString*)theFolder;
+ (void)incrementTaskWithName:(NSString*)theName WithValue:(int)theValue FromFolder:(NSString*)theFolder;
+ (void)resetTaskWithName:(NSString*)theName FromFolder:(NSString*)theFolder;
+ (void)resetTasksFromDatabaseFolder:(NSString*)theFolder;
+ (void)deleteTaskWithName:(NSString*)theName FromFolder:(NSString*)theFolder;
+ (void)resetPeriod:(int)thePeriod ForTaskWithName:(NSString*)theName FromFolder:(NSString*)theFolder;
+ (void)moveTaskWithName:(NSString*)theFirstName AboveTaskWithName:(NSString*)theSecondName FromFolder:(NSString*)theFolder;
+ (NSMutableArray *) executeSQL:(NSString*) theStatement ReturningRows:(int)numRows;
+ (NSArray*)deleteExistingTaskInDatabaseWithName:(NSString*)theName withFolder:(NSString *)theFolder;
+ (Boolean)checkUniquenessForTaskInDatabaseWithName:(NSString*)theName withFolder:(NSString *)theFolder;
+ (void)saveTaskInDatabaseWithName:(NSString *)theName withUnits:(NSString *)theUnits withFolder:(NSString *)theFolder withPeriod:(int)thePeriod withDate:(double)theDate withTarget:(NSInteger *)theTarget withProgress:(int)progress withPriority:(int) priority;
+ (NSString*) retrieveValue:(NSString*) theValue FromTask:(NSString*) theName FromFolder:(NSString*) theFolder;

@end
