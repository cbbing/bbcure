//
//  UICureTableCell.h
//  BBCure
//
//  Created by Chen on 15/6/4.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CureData.h"

//@protocol UICureTableCellDelegate <NSObject>
//
//-(void)addNewCureItem:(UIButton*)button;
//
//@end

@interface UICureTableCell : UITableViewCell

@property (strong, nonatomic) CureData *data;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cureDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *addNewCureButton;

//@property (weak, nonatomic) id<UICureTableCellDelegate> delegate;


@end
