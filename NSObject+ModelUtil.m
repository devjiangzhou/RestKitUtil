//
//  NSObject+JZModelUtil.m
//  RestKit
//
//  Created by Jiangzhou on 14-1-18.
//  Copyright (c) 2014年 bjz. All rights reserved.
//

#import "NSObject+ModelUtil.h"
#import <RestKit/ObjectMapping/RKObjectUtilities.h>
#import <objc/objc-class.h>

//@interface NSObject (Private)
//
///**
// *  为model的属性指定特殊的json映射key
// *
// *  @param mappingProperty key:customKey
// */
//+(RKObjectMapping*) registerCustomMappingProperty;
//@end

/**
 *  这个类已知问题是 两个对象不能互相引用
 */
@implementation NSObject (ModelUtil)

#pragma mark 注册mapping
+(RKObjectMapping*) registerDefaultMapping{
    RKObjectMapping *mapping = [self relationshipMapping:[self class] store:nil];
    return mapping;
}

#pragma mark 注册Entitymapping
+(RKEntityMapping*) registerEntitryMapping:(RKManagedObjectStore*) store{
    RKEntityMapping *mapping = [self relationshipMapping:[self class] store:store];
    return mapping;
}

#pragma mark 定制key
-(NSDictionary*)customMappingProperty{
    return nil;
}

+(RKObjectMapping*) registerCustomMappingProperty:(RKManagedObjectStore*) store{
//    if ([@"NSManagedObject" isEqualToString:NSStringFromClass(class_getSuperclass([self class]))]) {
//        //遗留问题。 如果runtime切换父类
//        class_setSuperclass([self class], [NSObject class]);
//        class_setSuperclass([self class], [NSObject class]);
//    }
    RKObjectMapping* mapping=[RKObjectMapping mappingForClass:[self class]];
    [mapping setForceCollectionMapping:YES];
    NSDictionary* value= [ [[[self class] alloc]init] performSelector:@selector(customMappingProperty)];
    if (value) {
        [mapping addAttributeMappingsFromDictionary:value];
        
        NSArray* vars=[self classVars:[self class]];
        for (int i=0; i<vars.count; i++) {
            Ivar var=(__bridge Ivar)([vars objectAtIndex:i]);
            [mapping addRelationshipMappingWithSourceKeyPath:[[NSString alloc] initWithCString:ivar_getName(var) encoding:NSUTF8StringEncoding] mapping:[self relationshipMapping:RKKeyValueCodingClassForObjCType(ivar_getTypeEncoding(var)) store:store]];
        }
    }else{
        mapping=nil;
    }
    return  mapping;
}


/**
 *  通过递归得到默认的属性
 *
 *  @param cls className
 *
 *  @return RKObjectMapping*
 */
+(id) relationshipMapping:(Class)cls store:(RKManagedObjectStore*) store{
    if (!store && [@"NSManagedObject" isEqualToString:NSStringFromClass(class_getSuperclass(cls))]) {
        //遗留问题... 暂时没有找到替代过期的方法  切换父类
        class_setSuperclass(cls, [NSObject class]);
        class_setSuperclass(cls, [NSObject class]);
    }else{
        class_setSuperclass(cls, [NSManagedObject class]);
        class_setSuperclass(cls, [NSManagedObject class]);
    }
    
    if ([cls class_isHaveMethod]) {
        return [cls registerCustomMappingProperty:store];
    }
    
    RKObjectMapping *mapping = store?[RKEntityMapping mappingForEntityForName:NSStringFromClass(cls) inManagedObjectStore:store]: [RKObjectMapping mappingForClass:cls];
    mapping.forceCollectionMapping=YES;
    
    unsigned int outCount;
    Ivar *vars=class_copyIvarList(cls, &outCount);
    
    NSMutableArray *propertys=[[NSMutableArray alloc]initWithCapacity:5];
    for (int i=0; i<outCount; i++) {
        
        Ivar var=vars[i];
        NSString *varName = [[NSString alloc] initWithCString:ivar_getName(var) encoding:NSUTF8StringEncoding];
        
        //添加引用对象 ps:通过判断Class中是否有属性
        unsigned int idCount;
        class_copyIvarList(RKKeyValueCodingClassForObjCType(ivar_getTypeEncoding(var)), &idCount);
        if (idCount>0) {
            RKObjectMapping* relationMapping=[self relationshipMapping:RKKeyValueCodingClassForObjCType(ivar_getTypeEncoding(var)) store:store];
            [mapping addRelationshipMappingWithSourceKeyPath:varName mapping:relationMapping];
        }else{
            //if ([cls respondsToSelector:@selector(getMappingDictionary)]) {
            //    NSDictionary* dic=[cls performSelector:@selector(getMappingDictionary)];
            //}
            [propertys addObject:varName];
        }
    }
    [mapping addAttributeMappingsFromArray:propertys];
    free(vars);
    return mapping;
}

+(BOOL)class_isHaveMethod{
    unsigned int outCount;
    Method   *methods= class_copyMethodList([self class], &outCount);
    BOOL isHave=NO;
    for (int i=0; i<outCount; i++) {
        Method method=methods[i];
        if (sel_isEqual(@selector(customMappingProperty), method_getName(method))) {
            isHave=YES;
        }
    }
    free(methods);
    return isHave;
}

+(NSArray*)classVars:(Class)cls{
    unsigned int outCount;
    Ivar *vars=class_copyIvarList(cls, &outCount);
    
    NSMutableArray *propertys=[[NSMutableArray alloc]initWithCapacity:5];
    for (int i=0; i<outCount; i++) {
        Ivar var=vars[i];
        //添加引用对象 ps:通过判断Class中是否有属性
        unsigned int idCount;
        class_copyIvarList(RKKeyValueCodingClassForObjCType(ivar_getTypeEncoding(var)), &idCount);
        if (idCount>0) {
            [propertys addObject:(__bridge id)(var)];
        }
    }
    free(vars);
    return propertys;
}

@end
