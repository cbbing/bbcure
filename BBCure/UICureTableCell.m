//
//  UICureTableCell.m
//  BBCure
//
//  Created by Chen on 15/6/4.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import "UICureTableCell.h"
#import "AddNewItemViewController.h"

@implementation UICureTableCell

-(void)setData:(CureData *)data
{
    _data = data;
    _titleLabel = self.titleLabel;
    _cureDurationLabel = self.cureDurationLabel;
    _dateLabel = self.dateLabel;

}

#pragma mark - event response


#pragma mark - getter

-(UILabel*)titleLabel
{
    _titleLabel.text = self.data.name;
    return _titleLabel;
}

-(UILabel*)cureDurationLabel
{
    NSString *str = @"";
    if (self.data.cureDuration <= 60) {
        str = [NSString stringWithFormat:@"%ld''", (long)self.data.cureDuration];
    }
    else
    {
        long minute = self.data.cureDuration/60;
        long second = self.data.cureDuration%60;
        str = [NSString stringWithFormat:@"%ld'%ld''", minute, second];
        
    }
    _cureDurationLabel.text = str;
    return _cureDurationLabel;
}

-(UILabel*)dateLabel
{
    NSTimeZone* GTMZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:GTMZone];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //NSDate *date = self.data.date;
    NSString *dateString = [dateFormatter stringFromDate:self.data.date];
    _dateLabel.text = dateString;
    return _dateLabel;
}

@end
