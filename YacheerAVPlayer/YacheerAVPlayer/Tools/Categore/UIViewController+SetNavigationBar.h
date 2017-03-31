//
//  UIViewController+SetNavigationBar.h
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SetNavigationBar)

- (void)setNavigationBarStyle:(UIStatusBarStyle)style isHideNavigationBar:(BOOL)ishide;

- (void)setnavigationControllerPopGestureRecognizer:(BOOL)isEnable;

@end
