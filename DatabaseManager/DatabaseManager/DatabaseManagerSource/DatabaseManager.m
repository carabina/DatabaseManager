//
//  DatabaseManager.m
//  YZTools<https://github.com/yangyongzheng/YZTools>
//
//  Created by yangyongzheng on 2017/4/22.
//  Copyright © 2017年 yyz. All rights reserved.
//

#import "DatabaseManager.h"
#import "DatabaseDbManagerWrapper.h"
#import "DatabaseQueueManagerWrapper.h"

@implementation DatabaseManager

#pragma mark - Public Method
+ (instancetype)sharedManager
{
    static DatabaseManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DatabaseManager alloc] init];
    });
    return manager;
}

#pragma mark -getter or setter
- (id<DatabaseDbManager>)dbManager
{
    return (id<DatabaseDbManager>)[DatabaseDbManagerWrapper sharedDbManager];
}

- (id<DatabaseQueueManager>)dbQueueManager
{
    return (id<DatabaseQueueManager>)[DatabaseQueueManagerWrapper sharedDbQueueManager];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
