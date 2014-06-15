//
//  DBClass.h
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



#define DBHandler [DBClass sharedHandler]
@interface DBClass : NSObject {
    NSManagedObjectContext *_manageContext;
    NSPersistentStoreCoordinator *_storeCordinator;
    NSPersistentStore *_persistentStore;
    
}

@property (readonly, nonatomic) NSManagedObjectContext *_manageContext;

// Insert Records
- (BOOL) insertObject:(id)manageObject;
- (BOOL) insertObject:(id)manageObject andSave:(BOOL)save;

// Delete Object
- (BOOL) deleteObject:(id)manageObject;
- (BOOL) deleteObject:(id)manageObject andSave:(BOOL)save;

//Update object
- (void) updateObject:(id)manageObject;

// Fetch Records
- (id) fetchObjectsOfEntity:(NSString *)entity;
- (id) fetchObjectsOfEntity:(NSString *)entity withExpressionDescription:(NSArray *)expDesc;
- (id) fetchObjectsOfEntity:(NSString *)entity withSortDescription:(NSArray *)sortDesc;
- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate;
- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDesc withExpressionDescription:(NSArray *)expDesc withResultType:(NSFetchRequestResultType)resultType;

// Get Entity Description
- (NSEntityDescription *) entityDescriptionForName:(NSString *)name;

// Save Context
- (BOOL) saveContext;

// Singleton Accessor
+ (DBClass *) sharedHandler;

// ManageObject for Entity
- (id) manageObjectForEntity:(id)entityName;
- (id) tmpManageObjectForEntity:(id)entityName;

@end
