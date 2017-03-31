//
//  UIBarButtonItem+BarButtonCustom.m
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "UIBarButtonItem+BarButtonCustom.h"

@implementation UIBarButtonItem (BarButtonCustom)

+ (UIBarButtonItem*)barWithTitleItem:(UIBarButtonItemStyle)sytle tag:(long)tag title:(NSString*)title aciton:(SEL)aciton target:(id)target
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:title style:sytle target:target action:aciton];
    item.tag = tag;
    return item;
}

+ (UIBarButtonItem*)barWithImageName:(NSString*)picName tag:(long)tag action:(SEL)action
                              target:(id)target
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 50, 30);
    [btn setBackgroundImage:[UIImage imageNamed:picName] forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    return barButtonItem;
}

@end
