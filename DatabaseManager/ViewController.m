//
//  ViewController.m
//  DatabaseManager
//
//  Created by 杨永正 on 2017/4/22.
//  Copyright © 2017年 yyz. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseHeader.h"
#import "DatabaseConstant.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)buttonClicked:(UIButton *)sender
{
    /*
     基于创建的工程资源plist文件升级数据库表字段
     1.创建数据库相对应的plist资源文件（注意本地创建plist结构，可看示例DatabaseManager->SupportFiles->BrowseRecords.plist）
     2.后续数据库版本升级，字段更新，只需按如下调用数据库升级方法即可。
     3.注意数据库名字、表名、资源文件plist名赋值
     */
    
    // 使用FMDatabase类进行数据库版本升级
    [self upgradeDatabaseVersionWithDb];
    
    // 使用FMDatabaseQueue类进行数据库版本升级
    [self upgradeDatabaseVersionWithDbQueue];
    
    // 使用dbQueueManager进行异步更新表字段
    [self asynUpgradeDatabaseVersionWithDbQueue];
}

#pragma mark - 升级数据库版本
- (void)upgradeDatabaseVersionWithDb
{
    [[DatabaseManager sharedManager].dbManager upgradeDatabaseVersionWithName:DbNameBrowseRecords
                                                                  dbExtension:DbExtensionDb
                                                                   dbPathType:DbPathTypeSandbox
                                                                   tableNames:@[DbTableNameSupplyList, DbTableNamePurchaseList]
                                                             resourceFileName:DbResourceBrowseRecords];
}

- (void)upgradeDatabaseVersionWithDbQueue
{
    [[DatabaseManager sharedManager].dbQueueManager upgradeDatabaseVersionWithName:DbNameBrowseRecords
                                                                       dbExtension:DbExtensionDb
                                                                        dbPathType:DbPathTypeSandbox
                                                                        tableNames:@[DbTableNameSupplyList, DbTableNamePurchaseList]
                                                                  resourceFileName:DbResourceBrowseRecords];
}

- (void)asynUpgradeDatabaseVersionWithDbQueue
{
    [[DatabaseManager sharedManager].dbQueueManager asynUpgradeDatabaseVersionWithName:DbNameBrowseRecords
                                                                           dbExtension:DbExtensionDb
                                                                            dbPathType:DbPathTypeSandbox
                                                                            tableNames:@[DbTableNameSupplyList, DbTableNamePurchaseList]
                                                                      resourceFileName:DbResourceBrowseRecords];
}

@end
