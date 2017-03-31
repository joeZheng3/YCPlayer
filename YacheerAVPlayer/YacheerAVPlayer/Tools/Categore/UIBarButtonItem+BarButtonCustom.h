//
//  UIBarButtonItem+BarButtonCustom.h
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (BarButtonCustom)

+ (UIBarButtonItem*)barWithTitleItem:(UIBarButtonItemStyle)sytle tag:(long)tag title:(NSString*)title aciton:(SEL)aciton target:(id)target;

+ (UIBarButtonItem*)barWithImageName:(NSString*)picName tag:(long)tag action:(SEL)action target:(id)target;

@end
