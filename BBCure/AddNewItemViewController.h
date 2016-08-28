//
//  AddNewItemViewController.h
//  BBCure
//
//  Created by Chen on 15/6/5.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIAddNewItemViewDelegate <NSObject>

-(void)refreshTableView;

@end

@interface AddNewItemViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) BOOL bEditing; //编辑还是增加
@property (strong, nonatomic) NSString *partName;//部位名称

@property (weak, nonatomic) UIPopoverController * popoverVC;

@property (weak, nonatomic) id<UIAddNewItemViewDelegate> delegate;

@end
