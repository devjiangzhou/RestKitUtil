//
//  JZObjectManager.m
//  RestKit
//
//  Created by Jiangzhou on 14-1-22.
//  Copyright (c) 2014年 bjz. All rights reserved.
//

#import "JZObjectManager.h"
#import <RestKit/CoreData.h>
#import <RestKit/Support.h>

@implementation JZObjectManager
+(RKObjectManager*)installManager{
    static RKObjectManager* objectManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objectManager=[RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://192.168.1.6:8080/pxsystem/JSON-RPC?debug=true"]];
    });
    return objectManager;
}
+(id)sharedJZManager{
    return [self installManager];
}
+(id)SharedJZCoreDataManager{
    RKObjectManager *objectManager=[self installManager];
    //创建coreData管理对象
    NSManagedObjectModel *managedObjectModel=[NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSError *error = nil;
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Store.sqlite"];
    NSLog(@"sqlite path is %@",path);
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (! persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    [managedObjectStore createManagedObjectContexts];
    objectManager.managedObjectStore = managedObjectStore;
    
    return objectManager;
}
@end
