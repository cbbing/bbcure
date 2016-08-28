//
//  CureData.m
//  BBCure
//
//  Created by Chen on 15/6/1.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import "CureData.h"

@implementation CureData

//重载选择 使用的LKDBHelper
+(LKDBHelper *)getUsingLKDBHelper
{
    static LKDBHelper* db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* dbpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/curedata.db"];
        db = [[LKDBHelper alloc]initWithDBPath:dbpath];
        //or
        //        db = [[LKDBHelper alloc]init];
    });
    return db;
}


+(NSString*)getTableName
{
    return @"CureTable";
}

@end
