//
//  YacheerPlayer.h
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^FullScreen)(BOOL flag);

@interface YacheerPlayer : UIView

@property (strong, nonatomic) IBOutlet UIView *containView;//容器视图

@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *playOrPauseBtn;
@property (strong, nonatomic) IBOutlet UIButton *prefixBtn;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLab;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLab;
@property (strong, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (strong, nonatomic) IBOutlet UIProgressView *videoProgressView;

@property (nonatomic,strong) UIActivityIndicatorView *acView; //显示加载
@property (nonatomic,strong) NSString *urlStr;//播放单个视频源
@property (nonatomic,strong) NSArray *urls; //播放一组视频
@property (nonatomic) int currentIndex; //当前索引
@property (nonatomic,strong) id observer;//播放器的时间监听
@property (nonatomic) float duration; //当前视频总时长

@property (nonatomic,strong) AVPlayer *player;//播放器对象
@property (nonatomic,strong) AVPlayerLayer *playerLayer; //播放器图层

@property (nonatomic,copy) FullScreen fs;

/**
 @功能说明：开始播放
 @参数说明：strURL 播放的视频源URL字符串，也可以是本地视频名称
 @返回值：无
 */
- (void)playerWithURLString:(NSString*)strURL;

/**
 @功能说明：开始播放
 @参数说明：urls 播放的一组视频源URL
 @返回值：无
 */
- (void)playerWithURLs:(NSArray*)urls;

/**
 @功能说明：根据父视图来同步子视图的frame
 @参数说明：无
 @返回值：无
 */
- (void)equalToFrame;

@end
