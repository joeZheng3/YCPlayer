//
//  YacheerPlayerVc.m
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "YacheerPlayerVc.h"
#import "YacheerPlayer.h"

@interface YacheerPlayerVc ()

@property (nonatomic,strong) NSMutableArray *aryData;
@property (nonatomic,strong) YacheerPlayer *player;

@end

@implementation YacheerPlayerVc

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置导航栏
    [self setNavigationBar];
    
    //准备数据源
    [self initWithData]; //拓展用
    
    //创建MP4
    [self MP4AVPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initData
- (void)initWithData
{
    self.aryData = [NSMutableArray array];
    //Todo
}

#pragma mark - 创建MP4
- (void)MP4AVPlayer
{
    self.player = (YacheerPlayer*)[[NSBundle mainBundle]loadNibNamed:@"YacheerPlayer" owner:self.view options:nil][0];
    self.player.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
    [self.view addSubview:self.player];
    
    //处理全屏和非全屏
    __weak typeof(self.player) weakPlayer = self.player;
    weakPlayer.fs = ^(BOOL flag){
        if (flag == YES) {  //全屏
            [[UIApplication sharedApplication]setStatusBarHidden:YES];//隐藏状态栏
            [self.navigationController setNavigationBarHidden:YES animated:YES];//隐藏导航栏
            
            [UIView animateWithDuration:0.3 animations:^{
                
                [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];//旋转状态栏为横屏
                
                self.view.transform = CGAffineTransformMakeRotation(M_PI/2);//旋转当前View为横屏
                
                CGRect bound = [UIScreen mainScreen].bounds;
                self.view.bounds = CGRectMake(0, 0, bound.size.height, bound.size.width); //只能改bounds
                
                weakPlayer.frame = self.view.bounds;
                weakPlayer.transform = CGAffineTransformMakeRotation(0); //旋转当前player正常显示
                [weakPlayer equalToFrame];//同步player上的子视图
                
            }];
        }
        else //非全屏
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];//显示状态栏
            [self.navigationController setNavigationBarHidden:NO animated:NO];//显示导航栏
            
            [UIView animateWithDuration:0.3 animations:^{
                [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
                self.view.transform = CGAffineTransformMakeRotation(0);
                
                CGRect bound = [UIScreen mainScreen].bounds;
                self.view.bounds = CGRectMake(0, 0, bound.size.width, bound.size.height-64);
                
                weakPlayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
                weakPlayer.transform = CGAffineTransformMakeRotation(0);
                [weakPlayer equalToFrame];//同步player上的子视图
            }];
        }
    };
    
    [self playMovie]; //播放视频
    
}

#pragma mark - Private Method
- (void)setNavigationBar
{
    self.title = @"Yacheer";
    self.navigationController.navigationBar.translucent = NO;
}

- (void)playMovie
{
#if 1
    //本地播放
    NSString *urlStr = [NSString stringWithFormat:@"2012年秋冬大片花絮.mp4"];
    [self.player playerWithURLString:urlStr];
#endif
    
#if 0
    //在线播放
    NSString *urlStr = [NSString stringWithFormat:@"http://112.74.108.147:6100/Upload/2015/11/11/2c6a070b-54c2-4afa-a52f-b40e2e667821.MP4"];
    [self.player playerWithURLString:urlStr];
#endif
    
#if 0
    //播放一组本地视频
    NSArray *urls = @[
                      @"2012春夏广告片短1.mp4",
                      @"2012春夏广告片短2.mp4",
                      @"2012年秋冬大片花絮.mp4"
                      ];
    [self.player playerWithURLs:urls];
#endif
    
#if 0
    //播放一组在线视频
    NSArray *urls = @[
                      @"http://112.74.108.147:6100/Upload/2015/11/11/2c0011df-6315-4167-9d30-bfb9c9aaa392.MP4",
                      @"http://112.74.108.147:6100/Upload/2015/11/11/6f55b525-e8ee-4e46-8621-bbd09a553cb8.MP4",
                      @"http://112.74.108.147:6100/Upload/2015/11/11/2c6a070b-54c2-4afa-a52f-b40e2e667821.MP4"
                      ];
    [self.player playerWithURLs:urls];
#endif

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
