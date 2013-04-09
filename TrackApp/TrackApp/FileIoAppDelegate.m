//
//  FileIoAppDelegate.m
//  TrackApp
//
//  Created by Collins, Brian C on 3/22/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "FileIoAppDelegate.h"

@implementation FileIoAppDelegate

- (NSMutableArray*) getDatabaseRows {
    //return a mutable array of arrays of strings. (NS)
    return nil;
}

- (NSString*) stringFromDatabase {
    NSMutableString* result = @"";
    
    NSString* rowText;
    //NSArray* row;
    NSMutableArray* rows = [self getDatabaseRows];
    
    // Fix the code so that it formats the string correctly.
    for(NSArray* row in rows) {
        rowText = [NSString stringWithFormat:@"%@,%@,%@\n", row[0], row[1], row[2]];
        [result appendString:rowText];
    }
    
    return result;
}

// Returns the path to the file.
- (NSString*) writeDataToFile {
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"report.csv";
    //path to write to
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    NSString* data = [self stringFromDatabase];
    NSError *error = nil;
    [data writeToFile:fileAtPath
            atomically:YES
            encoding:NSUTF8StringEncoding
            error:&error];
    
    return fileAtPath;
}

@end
