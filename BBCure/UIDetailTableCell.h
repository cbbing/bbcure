//
//  UIDetailTableCell.h
//  BBCure
//
//  Created by Chen on 15/6/6.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CureData.h"

@interface UIDetailTableCell : UITableViewCell

@property (strong, nonatomic) CureData *data;

@end
