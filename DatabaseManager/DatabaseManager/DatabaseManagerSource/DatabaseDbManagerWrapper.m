//
//  DatabaseDbManagerWrapper.m
//  YZTools<https://github.com/yangyongzheng/YZTools>
//
//  Created by yangyongzheng on 2017/4/22.
//  Copyright © 2017年 yyz. All rights reserved.
//

#import "DatabaseDbManagerWrapper.h"
#import "DatabaseManagerProtocol.h"
#import "DatabaseMacro.h"

@interface DatabaseDbManagerWrapper ()<DatabaseDbManager>

@property (strong, nonatomic) NSString *tableName;
@property (strong, nonatomic) NSString *resourceFileName;
@property (strong, nonatomic) NSDictionary *tableDict;

@end

@implementation DatabaseDbManagerWrapper

#pragma mark - Public Method
+ (instancetype)sharedDbManager
{
    static DatabaseDbManagerWrapper *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DatabaseDbManagerWrapper alloc] init];
    });
    return manager;
}

#pragma mark - Private Method
#pragma mark - DatabaseDbManager协议实现
/**
 创建db
 */
- (FMDatabase *)dbWithName:(NSString *)dbName
                 extension:(NSString *)extension
                  pathType:(DbPathType)pathType
{
    if (StringNonEmptyCheck(dbName)) {
        NSString *dbPath;
        if (pathType == DbPathTypeSandbox) {    // 沙盒
            NSString *dbFullName;
            if (StringNonEmptyCheck(extension)) {
                dbFullName = [dbName stringByAppendingPathExtension:extension];
            } else {
                dbFullName = [dbName stringByAppendingPathExtension:@"db"];
            }
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            dbPath = [documentsPath stringByAppendingPathComponent:dbFullName];
        } else if (pathType == DbPathTypeProjectResources) {    // 工程资源文件
            if (StringNonEmptyCheck(extension)) {
                dbPath = [[NSBundle mainBundle] pathForResource:dbName ofType:extension];
            } else {
                dbPath = [[NSBundle mainBundle] pathForResource:dbName ofType:@"db"];
            }
        }
        if (StringNonEmptyCheck(dbPath)) {
            FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
            return db;
        }
    }
    return nil;
}

/**
 升级数据库某一个表
 */
- (void)upgradeDatabaseVersionWithName:(NSString *)dbName
                           dbExtension:(NSString *)extension
                            dbPathType:(DbPathType)dbPathType
                             tableName:(NSString *)tableName
                      resourceFileName:(NSString *)resourceFileName
{
    if (StringNonEmptyCheck(dbName) && StringNonEmptyCheck(tableName) && StringNonEmptyCheck(resourceFileName)) {
        // 初始化赋值
        FMDatabase *db = [self dbWithName:dbName
                                extension:extension
                                 pathType:dbPathType];
        self.tableName = tableName;
        self.resourceFileName = resourceFileName;
        // 判断数据库中是否已存在该表，不存在就创建该表，存在判断表字段是否需要更新
        if ([db open]) {
            if ([db tableExists:tableName]) {
                [self updateDatabaseColumns:db];
            } else {
                BOOL result = [self createTableWithDb:db
                                            tableName:tableName
                                     resourceFileName:resourceFileName];
                NSString *correctDesc = [NSString stringWithFormat:@"数据库%@创建表%@成功...", dbName, tableName];
                NSString *errorDesc = [NSString stringWithFormat:@"数据库%@创建表%@失败...", dbName, tableName];
                DBAssertTrue(result, errorDesc);
                DBAssertFalse(result, correctDesc);
            }
            
            [db close];
        }
        [self reset];
    }
}

/**
 升级数据库的多个表
 */
- (void)upgradeDatabaseVersionWithName:(NSString *)dbName
                           dbExtension:(NSString *)extension
                            dbPathType:(DbPathType)dbPathType
                            tableNames:(NSArray *)tableNames
                      resourceFileName:(NSString *)resourceFileName
{
    if (StringNonEmptyCheck(dbName) && StringNonEmptyCheck(resourceFileName) && ArrayNonEmptyCheck(tableNames)) {
        // 初始化赋值
        FMDatabase *db = [self dbWithName:dbName
                                extension:extension
                                 pathType:dbPathType];
        self.resourceFileName = resourceFileName;
        // 判断沙盒是否已存在该表，不存在就创建该表，若存在判断表字段是否需要更新
        if ([db open]) {
            for (NSString *tableName in tableNames) {
                if (StringNonEmptyCheck(tableName)) {
                    self.tableName = tableName;
                    if ([db tableExists:tableName]) {
                        [self updateDatabaseColumns:db];
                    } else {
                        BOOL result = [self createTableWithDb:db
                                                    tableName:tableName
                                             resourceFileName:resourceFileName];
                        NSString *correctDesc = [NSString stringWithFormat:@"数据库%@创建表%@成功...", dbName, tableName];
                        NSString *errorDesc = [NSString stringWithFormat:@"数据库%@创建表%@失败...", dbName, tableName];
                        DBAssertTrue(result, errorDesc);
                        DBAssertFalse(result, correctDesc);
                    }
                }
            }
            
            [db close];
        }
        [self reset];
    }
}

/**
 创建表
 */
- (BOOL)createTableWithDb:(FMDatabase *)db
                tableName:(NSString *)tableName
         resourceFileName:(NSString *)resourceFileName
{
    if ([db tableExists:tableName]) {
        return YES; // 已存在表直接返回
    }
    NSString *sql = [self sqlStatementWithTableName:tableName
                                   resourceFileName:resourceFileName];
    return [db executeUpdate:sql];
}

/**
 删除表
 */
- (BOOL)deleteTableWithDb:(FMDatabase *)db
                tableName:(NSString *)tableName
{
    if ([db tableExists:tableName]) {
        NSString *sql = [NSString stringWithFormat:@"drop table %@", tableName];
        return [db executeUpdate:sql];
    } else {
        return YES; // 不存在该表直接返回YES
    }
}

#pragma mark - Misc
#pragma mark 更新数据库字段
- (void)updateDatabaseColumns:(FMDatabase *)db
{
    NSArray *differColumns = [self differColumnsResourceInTable:db];
    if (ArrayNonEmptyCheck(differColumns)) {
        // 有需要更新的字段
        NSMutableArray *needAddColumnSqls = [NSMutableArray arrayWithCapacity:differColumns.count];
        for (NSString *columnName in differColumns) {
            NSString *columnType = [self.tableDict objectForKey:columnName];
            NSString *addColumnSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", self.tableName, columnName, columnType];
            [needAddColumnSqls addObject:addColumnSql];
        }
        DBLog(needAddColumnSqls);
        if (ArrayNonEmptyCheck(needAddColumnSqls)) {
            [self db:db transactionUpdateColumns:needAddColumnSqls];
        }
    }
}

#pragma mark 事物提交
- (void)db:(FMDatabase *)db transactionUpdateColumns:(NSArray *)addColumnSqls
{
    if (ArrayNonEmptyCheck(addColumnSqls)) {
        [db beginTransaction];
        BOOL isRollBack = NO;
        @try {
            for (NSString *addColumnSql in addColumnSqls) {
                BOOL result = [db executeUpdate:addColumnSql];
                NSString *errorInfo = [NSString stringWithFormat:@"字段添加失败：%@", addColumnSql];
                DBAssertTrue(result, errorInfo);
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            [db rollback];
        }
        @finally {
            if (!isRollBack) {
                BOOL result = [db commit];
                if (result) {
                    DBLog(@"字段添加成功...");
                }
            }
        }
    }
}

#pragma mark 资源文件有而表里面没有的字段集
- (NSArray *)differColumnsResourceInTable:(FMDatabase *)db
{
    NSArray *tableColumns = [self tableColumnsKeys:db];
    NSArray *resourceColumns = [self resourceColumnsKeys];
    if (ArrayNonEmptyCheck(tableColumns) && ArrayNonEmptyCheck(resourceColumns)) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", tableColumns];
        NSArray *differColumns = [resourceColumns filteredArrayUsingPredicate:predicate];
        if (ArrayNonEmptyCheck(differColumns)) {
            NSString *differDesc = [NSString stringWithFormat:@"资源文件%@的表和本地表%@不同的字段集->%@", self.resourceFileName, self.tableName, differColumns];
            DBLog(differDesc);
            return differColumns;
        }
        NSString *differDesc = [NSString stringWithFormat:@"资源文件%@的表和本地表%@字段相同，无需更新...", self.resourceFileName, self.tableName];
        DBLog(differDesc);
    }
    return nil;
}

#pragma mark 表里面有而资源文件没有的字段集
- (NSArray *)differColumnsTableInResource:(FMDatabase *)db
{
    NSArray *tableColumns = [self tableColumnsKeys:db];
    NSArray *resourceColumns = [self resourceColumnsKeys];
    if (ArrayNonEmptyCheck(tableColumns) && ArrayNonEmptyCheck(resourceColumns)) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", resourceColumns];
        NSArray *differColumns = [tableColumns filteredArrayUsingPredicate:predicate];
        if (ArrayNonEmptyCheck(differColumns)) {
            NSString *differDesc = [NSString stringWithFormat:@"本地表%@和资源文件%@的表不同的字段集->%@", self.tableName, self.resourceFileName, differColumns];
            DBLog(differDesc);
            return differColumns;
        }
        NSString *differDesc = [NSString stringWithFormat:@"本地表%@和资源文件%@的表字段相同，无需更新...", self.tableName, self.resourceFileName];
        DBLog(differDesc);
    }
    return nil;
}

#pragma mark 本地数据库表的字段集
- (NSArray *)tableColumnsKeys:(FMDatabase *)db
{
    NSMutableArray *tempArray = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:self.tableName];
    while ([resultSet next]) {
        NSString *columnName = [resultSet stringForColumn:@"name"];
        if (StringNonEmptyCheck(columnName)) {
            [tempArray addObject:columnName];
        }
    }
    return ArrayNonEmptyCheck(tempArray) ? [tempArray copy] : nil;
}

#pragma mark 资源文件的字段集
- (NSArray *)resourceColumnsKeys
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.resourceFileName
                                                         ofType:RESOURCE_EXTENSION_PLIST];
    if (StringNonEmptyCheck(filePath)) {
        NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        self.tableDict = [rootDict objectForKey:self.tableName];
        return [self.tableDict allKeys];
    }
    return nil;
}

#pragma mark 根据表名和资源文件名返回sql语句
- (NSString *)sqlStatementWithTableName:(NSString *)tableName
                       resourceFileName:(NSString *)resourceFileName
{
    if (StringNonEmptyCheck(tableName) && StringNonEmptyCheck(resourceFileName)) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:resourceFileName
                                                             ofType:RESOURCE_EXTENSION_PLIST];
        if (StringNonEmptyCheck(filePath)) {
            NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
            NSDictionary *tableDict = [rootDict objectForKey:tableName];
            if (DictionaryNonEmptyCheck(tableDict)) {
                __block NSString *sql;
                [tableDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSString *element = [NSString stringWithFormat:@"%@ %@,", key, obj];    // 拼接字段和字段类型
                    sql = sql ? [sql stringByAppendingString:element] : element;
                }];
                sql = [sql substringToIndex:sql.length-1];
                sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", tableName, sql];
                return sql;
            }
        }
    }
    return nil;
}

#pragma mark - 重置为初始值
- (void)reset
{
    self.tableName = nil;
    self.resourceFileName = nil;
    self.tableDict = nil;
}

@end
