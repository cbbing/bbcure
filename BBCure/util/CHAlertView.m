//
//  CHAlertView.m
//  BBCure
//
//  Created by Chen on 16/9/21.
//  Copyright © 2016年 Chen. All rights reserved.
// http://www.jianshu.com/p/08a958eff378
//

#import "CHAlertView.h"
#import <objc/runtime.h>

const char *KCHAlertViewIndexBlock = "CHAlertViewIndexBlock";
const char *KCHAlertViewOkBlock = "CHAlertViewOkBlock";
const char *KCHAlertViewCancelBlock = "CHAlertViewCancelBlock";

@interface UIAlertView(CHAlertView)

@property (nonatomic,copy)CHAlertViewClickedWithIndex indexBlock;
@property (nonatomic,copy)CHAlertViewOkClicked okBlock;
@property (nonatomic,copy)CHAlertViewCancelClicked cancelBlock;

@end

@implementation UIAlertView(CHAlertView)

- (void)setIndexBlock:(CHAlertViewClickedWithIndex)indexBlock{
    objc_setAssociatedObject(self, KCHAlertViewIndexBlock, indexBlock, OBJC_ASSOCIATION_COPY);
}
- (CHAlertViewClickedWithIndex)indexBlock{
    return objc_getAssociatedObject(self, KCHAlertViewIndexBlock);
}

- (void)setOkBlock:(CHAlertViewOkClicked)okBlock{
    objc_setAssociatedObject(self, KCHAlertViewOkBlock, okBlock, OBJC_ASSOCIATION_COPY);
}
- (CHAlertViewOkClicked)okBlock{
    return objc_getAssociatedObject(self, KCHAlertViewOkBlock);
}

- (void)setCancelBlock:(CHAlertViewCancelClicked)cancelBlock{
    objc_setAssociatedObject(self, KCHAlertViewCancelBlock, cancelBlock, OBJC_ASSOCIATION_COPY);
}
-(CHAlertViewCancelClicked)cancelBlock{
    return objc_getAssociatedObject(self, KCHAlertViewCancelBlock);
}

@end

@interface CHAlertView ()<UIAlertViewDelegate>

@end

@implementation CHAlertView

#pragma mark -
+ (void)showCHAlertViewWithTitle:(NSString *)title message:(NSString *)msg cancleButtonTitle:(NSString *)cancelTitle okButtonTitle:(NSString *)okTitle otherButtonTitleArray:(NSArray*)otherTitleArray clickHandle:(CHAlertViewClickedWithIndex) handle{
    UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:handle ? self : nil cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
    if (handle) {
        alert.indexBlock = handle;
    }
    for (NSString *otherTitle in otherTitleArray) {
        [alert addButtonWithTitle:otherTitle];
    }
    [alert show];
}

#pragma mark -
+ (void)showCHAlertViewWithTitle:(NSString *)title message:(NSString *)msg cancleButtonTitle:(NSString *)cancelTitle okButtonTitle:(NSString *)okTitle okClickHandle:(CHAlertViewOkClicked)okHandle cancelClickHandle:(CHAlertViewCancelClicked)cancelClickHandle{
    UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle,nil];
    if (okHandle) {
        alert.okBlock = okHandle;
    }
    if (cancelTitle) {
        alert.cancelBlock = cancelClickHandle;
    }
    [alert show];
}

#pragma mark -
+ (void)showCHAlertViewWithTitle:(NSString *)title message:(NSString *)msg cancleButtonTitle:(NSString *)cancelTitle okButtonTitle:(NSString *)okTitle otherButtonTitleArray:(NSArray*)otherTitleArray{
    [self showCHAlertViewWithTitle:title message:msg cancleButtonTitle:cancelTitle okButtonTitle:okTitle otherButtonTitleArray:otherTitleArray clickHandle:nil];
}

#pragma mark - UIAlertViewDelegate
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.indexBlock) {
        alertView.indexBlock(buttonIndex);
    }else{
        if (buttonIndex == 0) {//取消
            if (alertView.cancelBlock) {
                alertView.cancelBlock();
            }
        }else{//确定
            if (alertView.okBlock) {
                alertView.okBlock();
            }
        }
    }
}

@end
