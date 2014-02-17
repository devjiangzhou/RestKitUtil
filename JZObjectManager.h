//
//  JZObjectManager.h
//  RestKit
//
//  Created by Jiangzhou on 14-1-22.
//  Copyright (c) 2014年 bjz. All rights reserved.
//

#import "RKObjectManager.h"

@interface JZObjectManager : RKObjectManager
+(id)sharedJZManager;
+(id)SharedJZCoreDataManager;
@end
