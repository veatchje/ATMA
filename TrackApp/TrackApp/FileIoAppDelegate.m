//
//  FileIoAppDelegate.m
//  TrackApp
//
//  Created by Collins, Brian C on 3/22/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

//Brian's code start

#import "FileIoAppDelegate.h"

@implementation FileIoAppDelegate

// A constructor for ease of use.
+ (FileIoAppDelegate *) constructWithFolderName:(NSString *) folderName Email:(NSString *) email
{
    return [[FileIoAppDelegate alloc] initWithFolderName: folderName Email: email];
}

- (FileIoAppDelegate *) initWithFolderName:(NSString *) folderName Email:(NSString *) email
{
    self = [super init];
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:DATABASE_NAME]];
    if (self)
    {
        [self setFolder: folderName];
        [self setEmail: email];
    }
    
    return self;
}

// Static methods start

// Ahmed's code start
- (NSMutableArray *) loadTaskNamesFromDatabase:(NSString *) theFolderName
{
    printf("In loadTaskNamesFromDatabase\n");
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray* names;
    
    names = [[NSMutableArray alloc] init];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT name from tasks where folder = \"%s\";", [theFolderName UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        printf("DB is open\n");
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            printf("Statement prepared\n");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                printf("Statement correct\n");
                NSString *nameField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [names addObject:nameField];
            }
            sqlite3_finalize(statement);
        } else {
            printf("%d\n", sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL));
        }
        sqlite3_close(atmaDB);
    }
    return names;
}

- (NSMutableArray *) loadCompletedTasksFromDatabase:(NSString *) theTaskName FromFolder:(NSString*) theFolderName
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray* allRows;
    NSArray* row;
    
    allRows = [[NSMutableArray alloc] init];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT current, target, completed from completedtasks where name = \"%s\" and folder = \"%s\";", [theTaskName UTF8String],[theFolderName UTF8String]];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {   // TODO: The code doesn't reach inside this if statement. Fix that plz.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *currentField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSString *targetField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSString *completedField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                
                row = [NSArray arrayWithObjects:currentField, targetField, completedField, nil];
                [allRows addObject:row];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
    return allRows;
}
// Ahmed's code end

- (NSString*) stringFromDatabase:(NSString *) theFolderName
{
    NSMutableString* result = [[NSMutableString alloc] init];
    
    NSString* fileHead = [NSString stringWithFormat:@"Folder Name:%@\n", theFolderName];
    [result appendString:fileHead];
    
    NSString* headString;
    NSString* rowText;
    
    NSArray* names = [self loadTaskNamesFromDatabase:theFolderName];
    
    for(NSString* name in names) {
        NSArray* rows = [self loadCompletedTasksFromDatabase:name FromFolder:theFolderName];
        headString = [NSString stringWithFormat:@"Task Name:%@\nCurrent Progress,Target Goal,Completed Date\n", name];
        //NSLog(headString);
        [result appendString:headString];
        for(NSArray* row in rows) {
            rowText = [NSString stringWithFormat:@"%@,%@,%@\n", row[0], row[1], row[2]];
            [result appendString:rowText];
        }
    }
    
    return result;
}

// Returns the path of the file.
- (NSString*) writeFolderToFile:(NSString *) theFolderName
{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"report.csv";
    
    //the path to write to
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    NSString* data = [self stringFromDatabase:theFolderName];
    NSError *error = nil;
    [data writeToFile:fileAtPath
           atomically:YES
             encoding:NSUTF8StringEncoding
                error:&error];
    
    return fileAtPath;
}

// Email functions
- (Boolean) sendFile:(NSString *) file ToEmail:(NSString *) email
{
    // TODO: everything...
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"Check out this image!"];
    
    return false;
}

// Top level function
- (void) collectAndSendDataFromFolder:(NSString *) folder ToEmail:(NSString *) email
{
    NSString* fileAtPath = [self writeFolderToFile:folder];
    Boolean success = [self sendFile:fileAtPath ToEmail:email];
    if (!success) printf("Unable to send file!\n");
}

// Start puplic methods

- (void) setFolder:(NSString *) folder
{
    folderToCollectFrom = folder;
}

- (void) setEmail:(NSString *) email
{
    emailToSendTo = email;
}

- (void) collectAndSendData
{
    [self collectAndSendDataFromFolder:folderToCollectFrom ToEmail:emailToSendTo];
}

@end

//Brian's code end
