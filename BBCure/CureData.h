//
//  CureData.h
//  BBCure
//
//  Created by Chen on 15/6/1.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LKDBHelper.h"

@interface CureData : NSObject

@property (nonatomic, strong) NSString *name; //部位名称
@property                     NSInteger cureDuration;//时长
@property (nonatomic, strong) NSDate *date; //日期
//@property (nonatomic) double timeIntervalSince1970;
@property (nonatomic, strong) NSString *note;//备注
@property (nonatomic, strong) UIImage *image;//图片
@property                     NSInteger status;//类型， 默认为0； 4为隐藏

@end
