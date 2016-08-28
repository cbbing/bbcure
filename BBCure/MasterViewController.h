//
//  MasterViewController.h
//  BBCure
//
//  Created by Chen on 15/5/31.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICureTableCell.h"
#import "AddNewItemViewController.h"
#import "BKCustomPasscodeViewController.h"
#import "WYPopoverController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController<UIPopoverControllerDelegate, UIAddNewItemViewDelegate, BKPasscodeViewControllerDelegate, WYPopoverControllerDelegate>
{
    UIPopoverController *_popover;
    WYPopoverController* popoverController;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSString          *passcode;
@property (nonatomic) NSUInteger                failedAttempts;
@property (strong, nonatomic) NSDate            *lockUntilDate;

@end

