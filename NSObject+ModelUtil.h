//
//  NSObject+JZModelUtil.h
//  RestKit
//
//  Created by Jiangzhou on 14-1-18.
//  Copyright (c) 2014年 bjz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface NSObject (ModelUtil)

-(NSDictionary*)customMappingProperty;

/**
 *  为model添加默认映射
 */
+(RKObjectMapping*) registerDefaultMapping;

+(RKEntityMapping*) registerEntitryMapping:(RKManagedObjectStore*) store;
@end
