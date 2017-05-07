//
//  DatabaseManagerProtocol.h
//  YZTools<https://github.com/yangyongzheng/YZTools>
//
//  Created by yangyongzheng on 2017/4/22.
//  Copyright © 2017年 yyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

#pragma mark - 数据库路径类型
typedef NS_ENUM(NSUInteger, DbPathType) {
    DbPathTypeSandbox,              // 沙盒路径
    DbPathTypeProjectResources,     // 工程资源文件路径
};

#pragma mark - 数据库协议基本方法
@protocol DatabaseBaseManager <NSObject>
/**
 升级数据库的某一个表

 @param dbName 本地数据库名
 @param extension 本地数据库扩展名
 @param dbPathType 数据库路径类型（沙盒或工程资源文件）
 @param tableName 待升级的表名
 @param resourceFileName 包含表及其字段／字段类型的plist资源文件名
 */
- (void)upgradeDatabaseVersionWithName:(NSString *)dbName
                           dbExtension:(NSString *)extension
                            dbPathType:(DbPathType)dbPathType
                             tableName:(NSString *)tableName
                      resourceFileName:(NSString *)resourceFileName;
/**
 升级数据库的多个表
 
 @param dbName 本地数据库名
 @param extension 本地数据库扩展名
 @param dbPathType 数据库路径类型（沙盒或工程资源文件）
 @param tableNames 包含待升级表名的数组
 @param resourceFileName 包含表及其字段／字段类型的plist资源文件名
 */
- (void)upgradeDatabaseVersionWithName:(NSString *)dbName
                           dbExtension:(NSString *)extension
                            dbPathType:(DbPathType)dbPathType
                            tableNames:(NSArray *)tableNames
                      resourceFileName:(NSString *)resourceFileName;
/**
 创建表（根据plist资源文件创建），注意该方法不负责打开和关闭数据库
 1.当沙盒中不存在该表时（即首次创建此表），表字段为最新的资源文件中字段。
 2.若已存在该表直接返回YES，不存在时创建表
 
 @param db 用于操作数据库
 @param tableName 表名
 @param resourceFileName 存储字段和字段类型的plist资源文件名
 @return 返回是否创表成功。
 */
- (BOOL)createTableWithDb:(FMDatabase *)db
                tableName:(NSString *)tableName
         resourceFileName:(NSString *)resourceFileName;
/**
 删除某一张表，注意该方法不负责打开和关闭数据库
 1. 数据库中存在该表时，执行删除操作；不存在该表时直接返回YES
 
 @param db db
 @param tableName 表名
 @return 是否删除成功
 */
- (BOOL)deleteTableWithDb:(FMDatabase *)db
                tableName:(NSString *)tableName;
@end

#pragma mark - DatabaseDbManager协议方法
@protocol DatabaseDbManager <DatabaseBaseManager>
/**
 根据数据库名和数据库路径类型创建db
 
 @param dbName 数据库名称
 @param extension 数据库扩展名，如db，传nil时默认为db扩展名
 @param pathType 数据库路径类型
 @return db
 */
- (FMDatabase *)dbWithName:(NSString *)dbName
                 extension:(NSString *)extension
                  pathType:(DbPathType)pathType;
@end

#pragma mark - DatabaseQueueManager协议方法
@protocol DatabaseQueueManager <DatabaseBaseManager>
/**
 根据数据库名和数据库路径类型创建dbQueue
 
 @param dbName 数据库名称
 @param extension 数据库扩展名，如db，传nil时默认为db扩展名
 @param pathType 数据库路径类型
 @return dbQueue
 */
- (FMDatabaseQueue *)dbQueueWithName:(NSString *)dbName
                           extension:(NSString *)extension
                            pathType:(DbPathType)pathType;

/**
 异步升级数据库的多个表
 
 @param dbName 本地数据库名
 @param extension 本地数据库扩展名
 @param dbPathType 数据库路径类型（沙盒或工程资源文件）
 @param tableNames 包含待升级表名的数组
 @param resourceFileName 包含表及其字段／字段类型的plist资源文件名
 */
- (void)asynUpgradeDatabaseVersionWithName:(NSString *)dbName
                               dbExtension:(NSString *)extension
                                dbPathType:(DbPathType)dbPathType
                                tableNames:(NSArray *)tableNames
                          resourceFileName:(NSString *)resourceFileName;

@end
