//
//  DatabaseManager.h
//  YZTools<https://github.com/yangyongzheng/YZTools>
//
//  Created by yangyongzheng on 2017/4/22.
//  Copyright © 2017年 yyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManagerProtocol.h"

@interface DatabaseManager : NSObject

+ (instancetype)sharedManager;

@property (strong, readonly, nonatomic) id<DatabaseDbManager>dbManager;             // Database Manager
@property (strong, readonly, nonatomic) id<DatabaseQueueManager>dbQueueManager;     // DatabaseQueue Manager

@end
