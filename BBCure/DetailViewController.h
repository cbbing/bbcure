//
//  DetailViewController.h
//  BBCure
//
//  Created by Chen on 15/5/31.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGallery.h"
#import "BEMSimpleLineGraphView.h"

@interface DetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (strong, nonatomic) NSString* detailName; //部位名称


@end

