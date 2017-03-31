//
//  YacheerMp3Player.h
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface YacheerMp3Player : UIView

@property (strong, nonatomic) IBOutlet UILabel *currentTimeLab;
@property (strong, nonatomic) IBOutlet UILabel *endTimeLab;
@property (strong, nonatomic) IBOutlet UIProgressView *cacheProgress;
@property (strong, nonatomic) IBOutlet UISlider *cacheSlider;
@property (strong, nonatomic) IBOutlet UISlider *volumSlider;
@property (strong, nonatomic) IBOutlet UIButton *playOrPause;
@property (strong, nonatomic) IBOutlet UILabel *volumLab;

@property (nonatomic) float volum;//播放音量
@property (nonatomic,strong) NSString *urlStr;//播放的单个音频源
@property (nonatomic,strong) NSArray *urls;//播放的一组音频源
@property (nonatomic) int currentIndex;//当前播放索引
@property (nonatomic,strong) id observer;//播放器的时间监听

@property (nonatomic,strong) AVPlayer *player;//播放器对象

/**
 @功能说明：开始播放
 @参数说明：strURL 播放的音频源URL字符串，也可以是本地音频名称
 @返回值：无
 */
- (void)playerWithURLString:(NSString*)strURL;

/**
 @功能说明：开始播放
 @参数说明：urls 播放的一组视频源URL
 @返回值：无
 */
- (void)playerWithURLs:(NSArray*)urls;

@end
