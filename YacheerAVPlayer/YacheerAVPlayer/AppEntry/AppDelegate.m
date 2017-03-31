//
//  AppDelegate.m
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "AppDelegate.h"
#import "YacheerPlayerVc.h"
#import "CustomNavigationVc.h"
#import "YacheerMp3PlayerVc.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Life Cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 设置主窗口,并设置根控制器
    self.window = [[UIWindow alloc]init];
    self.window.frame = [UIScreen mainScreen].bounds;
    
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //MP4
    [self FirstDemo];
    //MP3
//    [self SecondDemo];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)applicationDidEnterBackground:(UIApplication *)application {

}


- (void)applicationWillEnterForeground:(UIApplication *)application {

}


- (void)applicationDidBecomeActive:(UIApplication *)application {

}


- (void)applicationWillTerminate:(UIApplication *)application {

}

#pragma mark - 设置根控制器
- (void)FirstDemo
{
    YacheerPlayerVc *vc = [[YacheerPlayerVc alloc]init];
    CustomNavigationVc *navigationVc = [[CustomNavigationVc alloc]initWithRootViewController:vc];
    self.window.rootViewController = navigationVc;
}

- (void)SecondDemo
{
    YacheerMp3PlayerVc *vc = [[YacheerMp3PlayerVc alloc]init];
    CustomNavigationVc *navigationVc = [[CustomNavigationVc alloc]initWithRootViewController:vc];
    self.window.rootViewController = navigationVc;
}



@end
