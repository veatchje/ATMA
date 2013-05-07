//
//  DatabaseAccessors.m
//  TrackApp
//
//  Created by Al-Shaali, Ahmed on 5/4/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import "DatabaseAccessors.h"

@implementation DatabaseAccessors

- (void) initializeDatabase {
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:DATABASE_NAME]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:databasePath] == NO)
    {
        printf("Creating the database\n");
        const char * dbPath = [databasePath UTF8String];
        
        if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
        {
            char *errMsg;
            //Creates the folders table.
            const char *sql_stmt = "create table if not exists folders(name TEXT);";
            
            if (sqlite3_exec(atmaDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create Folders table";
            } else {
                //Here we load the initial values into the folders table.
                sqlite3_stmt *statement;
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO FOLDERS values (\"Business\")"];
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(atmaDB, insert_stmt, -1, &statement, NULL);
                
                if(sqlite3_step(statement) == SQLITE_DONE ) {
                    printf("Folder added");
                }
                
                insertSQL = [NSString stringWithFormat:@"INSERT INTO FOLDERS values (\"Personal\")"];
                insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(atmaDB, insert_stmt, -1, &statement, NULL);
                
                if(sqlite3_step(statement) == SQLITE_DONE ) {
                    printf("Folder added");
                }
            }
            
            //Creates the tasks table.
            sql_stmt = "create table if not exists tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, units TEXT, folder TEXT, period INTEGER, enddate TIME, current INTEGER, target INTEGER, priority INTEGER);";
            
            if (sqlite3_exec(atmaDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                printf("Failed to create Tasks table");
            } else {
                
            }
            
            //Creates the completedTasks table.
            sql_stmt = "create table if not exists completedtasks(name TEXT, units TEXT, folder TEXT, period INTEGER, completed TIME, current INTEGER, target INTEGER);";
            
            if (sqlite3_exec(atmaDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                printf("Failed to create completedTasks table");
            } else {
                
            }
            
            sqlite3_close(atmaDB);
        } else {
            //status.text = @"Failed to open/create database";
        }
    }

}

//Loads a list of all folder names into the folderNames array
- (NSMutableArray*) loadNamesFromDatabase
{
    NSMutableArray * toReturn = [[NSMutableArray alloc] init];
    NSString *querySQL = [NSString stringWithFormat:@"SELECT name from folders;"];
    [toReturn addObjectsFromArray:[self executeSQL:querySQL ReturningRows:1]];
    return toReturn;
}



//Saves a given folder name into the folders table.
- (void)saveNameInDatabase:(NSString *)theName {
    NSString *insertSQL = [NSString stringWithFormat:@"insert into folders values(\"%@\");", theName];
    [self executeSQL:insertSQL];
}

//Deletes a given folder from the folders table. Also deletes all tasks in that folder, and all completedTasks from that folder.
- (void) deleteFolder:(NSString *) theName {
    NSString *insertSQL = [NSString stringWithFormat:@"delete from folders where name = \"%@\";", theName];
    [self executeSQL:insertSQL];
    insertSQL = [NSString stringWithFormat:@"delete from tasks where folder = \"%@\";", theName];
    [self executeSQL:insertSQL];
    insertSQL = [NSString stringWithFormat:@"delete from completedtasks where folder = \"%@\";", theName];
    [self executeSQL:insertSQL];
}

//Loads all relevant task information into the appropriate arrays.
- (NSMutableArray*)loadTasksFromDatabaseForFolder:(NSString*)theFolder
{
    NSString *querySQL = [NSString stringWithFormat:@"SELECT name, units, period, enddate, current, target from tasks where folder = \"%s\" order by priority ASC;", [theFolder UTF8String]];
    NSMutableArray* rows = [self executeSQL:querySQL ReturningRows:6];
    return rows;
    
    //    [self.taskNames removeAllObjects];
    //    [self.taskUnits removeAllObjects];
    //    [self.taskPeriods removeAllObjects];
    //    [self.taskEndDates removeAllObjects];
    //    [self.taskCurrents removeAllObjects];
    //    [self.taskTargets removeAllObjects];
    //    [self.visibleBools removeAllObjects];
    
    //for (int i = 0; i < [rows count]; i++)
    // {
    //        [self.taskNames addObject:[[rows objectAtIndex:i] objectAtIndex:0]];
    //        [self.taskUnits addObject:[[rows objectAtIndex:i] objectAtIndex:1]];
    //        [self.taskPeriods addObject:[[rows objectAtIndex:i] objectAtIndex:2]];
    //        [self.taskEndDates addObject:[self DayFormat:[[[rows objectAtIndex:i] objectAtIndex:3] integerValue]]];
    //        [self.taskCurrents addObject:[[rows objectAtIndex:i] objectAtIndex:4]];
    //        [self.taskTargets addObject:[[rows objectAtIndex:i] objectAtIndex:5]];
    //        [self.visibleBools addObject:@"false"];
    
    //NSString*  = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_colu]
    //}
    
}

//Increments a task by 1.
- (void)incrementTaskWithName:(NSString*)theName FromFolder:(NSString*)theFolder
{
    NSString *querySQL = [NSString stringWithFormat:@"update tasks set current =current+1 where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [theFolder UTF8String]];
    [self executeSQL:querySQL];
}

//Changes the current value of a task to the indicated amount.
- (void)incrementTaskWithName:(NSString*)theName WithValue:(int)theValue FromFolder:(NSString*)theFolder
{
    NSString *querySQL = [NSString stringWithFormat:@"update tasks set current =%d where name = \"%s\" and folder = \"%s\";", theValue, [theName UTF8String], [theFolder UTF8String]];
    [self executeSQL:querySQL];
}

//This function resets the progress of a given task
- (void)resetTaskWithName:(NSString*)theName FromFolder:(NSString*)theFolder
{
    NSString *querySQL = [NSString stringWithFormat:@"update tasks set current =0 where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [theFolder UTF8String]];
    [self executeSQL:querySQL];
}

//This function resets the progress of all the tasks in the given folder
- (void)resetTasksFromDatabaseFolder:(NSString*)theFolder
{
    NSString *querySQL = [NSString stringWithFormat:@"update tasks set current =0 where folder = \"%s\";", [theFolder UTF8String]];
    [self executeSQL:querySQL];
}

// Deletes a task and it's associated completedTasks from the database.
- (void)deleteTaskWithName:(NSString*)theName FromFolder:(NSString*)theFolder
{
    NSString *querySQL = [NSString stringWithFormat:@"delete from tasks where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [theFolder UTF8String]];
    [self executeSQL:querySQL];
    querySQL = [NSString stringWithFormat:@"delete from completedtasks where name = \"%s\" and folder = \"%s\";", [theName UTF8String], [theFolder UTF8String]];
    [self executeSQL:querySQL];
}

//This indicates that a task has been completed and resets it, incrementing the end date appropriately and adding it to the completedTasks table.
- (void)resetPeriod:(int)thePeriod ForTaskWithName:(NSString*)theName FromFolder:(NSString*)theFolder
{
    
    int enddate = 0;
    unsigned long interval;
    double total = 0;
    int current = 0;
    int target = 0;
    
    NSDate* today = [NSDate date];
    double today_in_seconds = [today timeIntervalSince1970];
    current = [[self retrieveValue:@"current" FromTask:theName FromFolder:theFolder] intValue];
    target = [[self retrieveValue:@"target" FromTask:theName FromFolder:theFolder] intValue];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO completedtasks (name, folder, period, current, target, completed) values (\"%@\", \"%s\", %d, %d, %d, %f)", theName, [theFolder UTF8String], thePeriod, current, target, today_in_seconds];
    [self executeSQL:insertSQL];
    
    enddate = [[self retrieveValue:@"enddate" FromTask:theName FromFolder:theFolder] intValue];
    
    if (thePeriod==-40){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *nextPeriod=[NSDate date];
        NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit  | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:today];
        [dateComponents setMonth:[dateComponents month]+1];
        nextPeriod = [calendar dateFromComponents:dateComponents];
        int daysInNextMonth = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:nextPeriod].length;
        [dateComponents setDay:daysInNextMonth];
        nextPeriod = [calendar dateFromComponents:dateComponents];
        total = [nextPeriod timeIntervalSince1970];
        
    }
    else if (thePeriod < 0)
    {
        thePeriod *= (-1);
        //basically, take the min of the period and the number of days next month, then set thePeriod to be the number of days difference between the two.
        //TODO: Fix the calendar code so that it works for the onth after the enddate, not the current date.
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *nextPeriod=[NSDate date];
        NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit  | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:today];
        [dateComponents setMonth:[dateComponents month]+1];
        nextPeriod = [calendar dateFromComponents:dateComponents];
        int daysInNextMonth = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:nextPeriod].length;
        
        thePeriod = MIN(daysInNextMonth, thePeriod);
        [dateComponents setDay:thePeriod];
        nextPeriod = [calendar dateFromComponents:dateComponents];
        total = [nextPeriod timeIntervalSince1970];
        //printf("%f today1\n ",[today timeIntervalSince1970]);
        
    } else {
        interval = thePeriod*24*3600;
        printf("%ld\n", interval);
        total = enddate + interval;
        while (total < today_in_seconds)
        {
            total += interval;
        }
    }
    
    insertSQL = [NSString stringWithFormat:@"update tasks set enddate = %f where name = \"%s\" and folder = \"%s\";", total, [theName UTF8String], [theFolder UTF8String]];
    [self executeSQL:insertSQL];
}


-(void)moveTaskWithName:(NSString*)theFirstName AboveTaskWithName:(NSString*)theSecondName FromFolder:(NSString*)theFolder
{
    NSString *querySQL;
    int priority = 0;
    if (![theSecondName isEqualToString:@""]) {
        priority = [[self retrieveValue:@"priority" FromTask:theSecondName FromFolder:theFolder] intValue];
    } else {
        querySQL = [NSString stringWithFormat:@"select max(priority) from tasks where folder = \"%s\";", [theFolder UTF8String]];
        priority = [[[[self executeSQL:querySQL ReturningRows:1] objectAtIndex:0] objectAtIndex:0] integerValue];
        priority++;
    }
    querySQL = [NSString stringWithFormat:@"update tasks set priority = priority+1 where priority >= %d and folder = \"%s\";", priority, [theFolder UTF8String]];
    [self executeSQL:querySQL];
    querySQL = [NSString stringWithFormat:@"update tasks set priority = %d where name = \"%s\" and folder = \"%s\";", priority, [theFirstName UTF8String], [theFolder UTF8String]];
    [self executeSQL:querySQL];
}

//Prepares the database for change. Probably magic.
- (void)prepareDatabase {
    NSError *err=nil;
    NSFileManager *fm=[NSFileManager defaultManager];
    
    NSArray *arrPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, -1);
    NSString *path=[arrPaths objectAtIndex:0];
    NSString *path2= [path stringByAppendingPathComponent:@"atmadatabase.sql"];
    
    
    if(![fm fileExistsAtPath:path2])
    {
        
        bool success=[fm copyItemAtPath:databasePath toPath:path2 error:&err];
        if(success)
            NSLog(@"file copied successfully");
        else
            NSLog(@"file not copied");
        
    }
}

- (NSString*) retrieveValue:(NSString*) theValue FromTask:(NSString*) theName FromFolder:(NSString*) theFolder
{
    NSString *querySQL = [NSString stringWithFormat:@"select %s from tasks where name = \"%s\" and folder = \"%s\";", [theValue UTF8String], [theName UTF8String], [theFolder UTF8String]];
    return [[[self executeSQL:querySQL ReturningRows:1] objectAtIndex:0] objectAtIndex:0];
}

- (void) executeSQL:(NSString*) theStatement
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    [self prepareDatabase];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        const char *query_stmt = [theStatement UTF8String];
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
}

- (NSMutableArray *) executeSQL:(NSString*) theStatement ReturningRows:(int)numRows
{
    const char *dbPath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray* allRows;
    NSArray* row;
    NSString* stringArray[numRows];
    
    allRows = [[NSMutableArray alloc] init];
    
    if (sqlite3_open(dbPath, &atmaDB) == SQLITE_OK)
    {
        const char *query_stmt = [theStatement UTF8String];
        
        if (sqlite3_prepare(atmaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (numRows == 1)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString * obj = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    [allRows addObject:obj];
                }
            } else {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    for (int i  = 0; i < numRows; i++)
                    {
                        stringArray[i] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i)];
                    }
                    
                    row = [NSArray arrayWithObjects:stringArray count:numRows];
                    [allRows addObject:row];
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(atmaDB);
    }
    return allRows;
}

@end
