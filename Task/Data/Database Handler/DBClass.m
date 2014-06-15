//
//  DBClass.m
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.

#import "DBClass.h"

#define SQLITE_FILE      @"DBModel.sqlite"
#define SQLITE_FILE_NAME @"DBModel"
#define SQLITE_FILE_EXT  @"sqlite"

#define COREDATA_DATAMODEL_EXT @"momd"

@implementation DBClass
@synthesize _manageContext;

static DBClass *sharedObject;



- (id) init
{
    self = [super init];
    if (self)
    {
        NSError *error = nil;
#if TESTING==1
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SQLITE_FILE]]){
            [[NSFileManager defaultManager] removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SQLITE_FILE] error:nil];
        }
#endif
        NSManagedObjectModel *_model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:SQLITE_FILE_NAME withExtension:COREDATA_DATAMODEL_EXT]];
        
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        
        _storeCordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        error = nil;
        if ([_storeCordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SQLITE_FILE]] options:options error:&error]){
            _manageContext = [[NSManagedObjectContext alloc] init];
            [_manageContext setPersistentStoreCoordinator:_storeCordinator];
        }
        else{
            NSLog(@"Error >>> %@", [error description]);
        }
    }
    
    return self;
}

+ (DBClass *) sharedHandler{
    @synchronized(sharedObject)
    {
        if (!sharedObject)
        {
            sharedObject = [[DBClass alloc] init];
        }
    }
    return sharedObject;
}

- (id) manageObjectForEntity:(id)entityName
{
    if ([entityName isKindOfClass:[NSString class]])
    {
        Class cls = NSClassFromString(entityName);
        
        id _manageObject = [[cls alloc] initWithEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:[DBHandler _manageContext]] insertIntoManagedObjectContext:[DBHandler _manageContext]];
        
        if (_manageObject)
            return _manageObject;
    }
    
    return nil;
}

- (id) tmpManageObjectForEntity:(id)entityName {
    if ([entityName isKindOfClass:[NSString class]])
    {
        Class cls = NSClassFromString(entityName);
        
        id _manageObject = [[cls alloc] initWithEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:[DBHandler _manageContext]] insertIntoManagedObjectContext:nil];
        
        if (_manageObject)
            return _manageObject;
    }
    
    return nil;
}

#pragma mark
#pragma mark Insert Record

- (BOOL) insertObject:(id)manageObject{
    return [self insertObject:manageObject andSave:YES];
}

- (BOOL) insertObject:(id)manageObject andSave:(BOOL)save{
    [_manageContext insertObject:manageObject];
    
    if (save)
        return [self saveContext];
    else
        return true;
    
    return false;
}

#pragma mark
#pragma mark Update Record


- (void) updateObject:(id)manageObject{
	[_manageContext updatedObjects];
    [self saveContext];
    
}


#pragma mark
#pragma mark Delete Record
- (BOOL) deleteObject:(id)manageObject{
    return [self deleteObject:manageObject andSave:YES];
}

- (BOOL) deleteObject:(id)manageObject andSave:(BOOL)save{
    [_manageContext deleteObject:manageObject];
    if (save)
        return [self saveContext];
    else
        return true;
    
    return false;
}

#pragma mark
#pragma mark Save Record
- (BOOL) saveContext{
    NSError *error = nil;
    if (![_manageContext save:&error]){
        NSLog(@"Error: %@", error);
        return false;
    }
    return true;
}

#pragma mark
#pragma mark Fetch Records

- (id) fetchObjectsOfEntity:(NSString *)entity{
    return [self fetchObjectsOfEntity:entity usingPredicate:nil withSortDescriptors:nil withExpressionDescription:nil withResultType:NSManagedObjectResultType];
}

- (id) fetchObjectsOfEntity:(NSString *)entity withExpressionDescription:(NSArray *)expDesc{
    return [self fetchObjectsOfEntity:entity usingPredicate:nil withSortDescriptors:nil withExpressionDescription:expDesc withResultType:NSDictionaryResultType];
}

- (id) fetchObjectsOfEntity:(NSString *)entity withSortDescription:(NSArray *)sortDesc{
    return [self fetchObjectsOfEntity:entity usingPredicate:nil withSortDescriptors:sortDesc withExpressionDescription:nil withResultType:NSDictionaryResultType];
}

- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate{
    return [self fetchObjectsOfEntity:entity usingPredicate:predicate withSortDescriptors:nil withExpressionDescription:nil withResultType:NSManagedObjectResultType];
}

- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDesc withExpressionDescription:(NSArray *)expDesc withResultType:(NSFetchRequestResultType)resultType{
    NSFetchRequest *_request = nil;
    NSArray *objects = nil;
    NSError *error = nil;
    
    @try
    {
        _request = [[NSFetchRequest alloc] init];
        [_request setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:_manageContext]];
        
        if (predicate)
            [_request setPredicate:predicate]; // Predicate
        
        if (sortDesc)
            [_request setSortDescriptors:sortDesc]; // Sort Descriptors
        
        if (expDesc)
            [_request setPropertiesToFetch:expDesc]; // Expression Descriptions (for using aggregate functions in CoreData)
        
        [_request setResultType:resultType];
        
        objects = [_manageContext executeFetchRequest:_request error:&error];
    }
    @catch(NSException *ex){
    }
    @finally {
        if (!error)
        {
            return objects;
        }
    }
    
    // show fetch error
    
    return nil;
}

- (NSEntityDescription *) entityDescriptionForName:(NSString *)name
{
    return [NSEntityDescription entityForName:name inManagedObjectContext:_manageContext];
}

@end
