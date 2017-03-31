//
//  UIViewController+SetNavigationBar.m
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "UIViewController+SetNavigationBar.h"

@implementation UIViewController (SetNavigationBar)

- (void)setNavigationBarStyle:(UIStatusBarStyle)style isHideNavigationBar:(BOOL)ishide
{
    [[UIApplication sharedApplication]setStatusBarStyle:style animated:YES];
    self.navigationController.navigationBar.hidden = ishide;
}

- (void)setnavigationControllerPopGestureRecognizer:(BOOL)isEnable
{
    if ([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = isEnable;
        if (isEnable) {
            self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
        }
    }
}

@end
