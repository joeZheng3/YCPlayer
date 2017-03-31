//
//  YacheerMp3Player.m
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "YacheerMp3Player.h"

@implementation YacheerMp3Player

#pragma mark - awakeFromNib 初始化xib文件上的子视图控件
/**
 @功能说明：初始化xib文件上的子视图控件，该方法是系统方法，用于初始化xib文件内容
 @参数说明：无
 @返回值：无
 */
- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentIndex = 0;//默认播放索引为0
    self.volum = 1.0;//默认播放音量为1.0，即最大音量
}

#pragma mark - 开始播放
/**
 @功能说明：开始播放
 @参数说明：strURL 播放的音频源URL字符串，也可以是本地音频名称
 @返回值：无
 */
- (void)playerWithURLString:(NSString*)strURL{
    self.urlStr = strURL;
    [self removeObserver];//首先移出播放监听事件
    [self createPlayer];//添加音频播放器
    [self addObserver];//添加监听事件
}

/**
 @功能说明：开始播放
 @参数说明：urls 播放的一组音频源URL
 @返回值：无
 */
- (void)playerWithURLs:(NSArray*)urls{
    self.urls = urls;
    if (self.urls && self.urls.count > 0) {
        NSString *urlStr = self.urls[self.currentIndex];
        [self playerWithURLString:urlStr];
    }
}

#pragma mark - 创建播放器，播放单个网络mp3或本地mp3
/**
 @功能说明：创建播放器，播放单个网络mp3或本地mp3
 @参数说明：无
 @返回值：无
 */
-(void)createPlayer {
    if (self.player) {
        [self.player pause];
        self.player = nil;
    }
    
    if (self.urlStr && self.urlStr.length > 0) {
        NSURL *url = nil;
        if ([self.urlStr hasPrefix:@"http"]) {//在线播放
            url = [NSURL URLWithString:[self.urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        } else {//本地播放
            NSString *file=[[NSBundle mainBundle] pathForResource:self.urlStr ofType:nil];
            url = [NSURL fileURLWithPath:file];
        }
        
        if (url) {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.player.volume = self.volum;//设置音量
            self.volumSlider.value = self.volum;
            self.volumLab.text = [NSString stringWithFormat:@"%.1f",self.volum];
        }
    }
}

#pragma mark - 给AVPlayerItem添加监听事件 (播放结束监听,播放状态监听,音频缓冲监听,播放进度监听)
/**
 @功能说明：给AVPlayerItem添加监听事件 (播放结束监听,播放状态监听,音频缓冲监听,播放进度监听)
 @参数说明：无
 @返回值：无
 */
-(void)addObserver {
    if (self.player) {
        AVPlayerItem *playerItem = self.player.currentItem;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];//播放结束监听
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];//监听播放状态属性
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];//监听音频缓冲属性
        [self addProgressObserver:playerItem];//监听播放进度
    }
}

#pragma mark - 移除AVPlayerItem的监听事件（移除播放结束监听,播放状态监听,加载网络监听,更新进度监听）
/**
 @功能说明：移除AVPlayerItem的监听事件（移除播放结束监听,播放状态监听,加载网络监听,更新进度监听）
 @参数说明：无
 @返回值：无
 */
-(void)removeObserver {
    if (self.player) {
        AVPlayerItem *playerItem = self.player.currentItem;
        [[NSNotificationCenter defaultCenter] removeObserver:self];//移出播放结束监听
        [playerItem removeObserver:self forKeyPath:@"status"];//移出播放状态监听
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];//移出音频缓冲监听
        [self.player removeTimeObserver:self.observer];
    }
}

#pragma mark - 播放完成通知
/**
 @功能说明：播放完成通知
 @参数说明：notification 通知对象
 @返回值：无
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"音频播放结束了");
    AVPlayerItem *playerItem = self.player.currentItem;
    self.currentTimeLab.text = [self convertTime:CMTimeGetSeconds(playerItem.duration)];
    [self.cacheSlider setValue:1.0 animated:YES];
    [self.playOrPause setTitle:@"播放" forState:UIControlStateNormal];
}

#pragma mark -计算时间，返回字符串
/**
 @功能说明：计算时间，返回字符串
 @参数说明：播放秒数
 @返回值：返回秒数对应的字符串
 */
- (NSString *)convertTime:(CGFloat)second{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {//如果大于或等于1小时
        int hour = second/3600;
        if (hour < 10) {
            [formatter setDateFormat:[NSString stringWithFormat:@"0%d:mm:ss",hour]];
        } else {
            [formatter setDateFormat:[NSString stringWithFormat:@"%d:mm:ss",hour]];
        }
    } else {//小于1小时
        [formatter setDateFormat:@"00:mm:ss"];
    }
    
    NSString *strTimer = [formatter stringFromDate:date];
    
    return strTimer;
}

#pragma mark - 给播放器添加更新进度监听,每秒监听一次
/**
 @功能说明：给播放器添加更新进度监听,每秒监听一次
 @参数说明：playerItem AVPlayerItem对象
 @返回值：无
 */
-(void)addProgressObserver:(AVPlayerItem*)playerItem {
    //这里设置每秒执行一次
    __weak YacheerMp3Player *weakSelf = self;
    float total = CMTimeGetSeconds([playerItem duration]);//总时间（秒）
    weakSelf.endTimeLab.text = [weakSelf convertTime:total];//总时长（秒）
    self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);//当前时间（秒）
        if (current && current >= 0 && current < total) {
            weakSelf.currentTimeLab.text = [weakSelf convertTime:current];
            //NSLog(@"当前已播放时长%@", weakSelf.currentTimeLab.text);
            [weakSelf.cacheSlider setValue:current/total animated:YES];
        }
    }];
}

#pragma mark - 通过KVO监控播放器状态
/**
 @功能说明：通过KVO监控播放器状态
 @参数说明：keyPath 监控的属性，object 监视的对象，change 状态改变，context 上下文
 @返回值：无
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayerItem *playerItem = object;
    if([keyPath isEqualToString:@"status"]){
        AVPlayerItemStatus status = playerItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            float duration = CMTimeGetSeconds(playerItem.duration);
            self.endTimeLab.text = [self convertTime:duration];//显示总时长
            //NSLog(@"音频总时长%@", self.endTimeLab.text);
        }
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds+durationSeconds;//缓冲总长度
        float progress = totalBuffer/CMTimeGetSeconds(playerItem.duration);
        [self.cacheProgress setProgress:progress animated:YES];
        //NSLog(@"音频缓冲时长%@", [self convertTime:totalBuffer]);
    }
}

#pragma mark - xib上的子控件响应方法
/**
 @功能说明：缓冲滑块值改变时回调
 @参数说明：sender 当前缓存滑块
 @返回值：无
 */
- (IBAction)cacheSliderValueChanged {
    AVPlayerItem *playerItem = self.player.currentItem;
    CGFloat value = self.cacheSlider.value;
    CGFloat duration = CMTimeGetSeconds(playerItem.duration);
    
    [self.player seekToTime:CMTimeMakeWithSeconds(value * duration, 1)];//从当前位置播放
    if (value >= 1.0) {
        [self.player seekToTime:CMTimeMakeWithSeconds(1.0 * duration, 1)];
        self.currentTimeLab.text = [self convertTime:duration];
    }
    
    //这里需要暂停,防止造成拖动时进度条卡顿
    [self.player pause];
    
}

/**
 @功能说明：滑块按下后移动，然后松手时回调
 @参数说明：sender 当前缓存滑块
 @返回值：无
 */
- (IBAction)cacheSliderTouchUpInside {
    [self.player play];
    [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
}

/**
 @功能说明：mp3播放 or 暂停
 @参数说明：sender 当前按钮
 @返回值：无
 */
- (IBAction)playOrPauseClicked {
    if(self.player.rate == 0){ //暂停
        [self.player play];
        [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
    }else if(self.player.rate == 1){//播放
        [self.player pause];
        [self.playOrPause setTitle:@"播放" forState:UIControlStateNormal];
    }
}

/**
 @功能说明：重播
 @参数说明：sender 当前按钮
 @返回值：无
 */
- (IBAction)resetPlay {
    if (self.player) {
        self.cacheSlider.value = 0.0;
        self.cacheProgress.progress = 0.0;
        self.volumLab.text = @"1.0";
        [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
        self.currentTimeLab.text = @"00:00:00";//重置当前播放时间
        [self.player seekToTime:CMTimeMakeWithSeconds(0, 1)];//设置音频为第一帧
        [self.player play];
    }
}

/**
 @功能说明：前一首 按钮按下回调
 @参数说明：sender 当前按钮
 @返回值：无
 */
- (IBAction)prefixClicked {
    if (self.urls && self.urls.count > 0) {
        self.currentIndex--;
        if (self.currentIndex <= 0) {
            self.currentIndex = 0;
            NSLog(@"已经是第一个音频了！");
        }
        
        if (self.player) {
            NSURL *url = nil;
            self.urlStr = self.urls[self.currentIndex];
            if ([self.urlStr hasPrefix:@"http"]) {//在线播放
                url = [NSURL URLWithString:[self.urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            } else {//本地播放
                NSString *file=[[NSBundle mainBundle] pathForResource:self.urlStr ofType:nil];
                url = [NSURL fileURLWithPath:file];
            }
            
            if (url) {
                [self.player pause];
                [self removeObserver];//首先移出播放监听事件
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                [self.player replaceCurrentItemWithPlayerItem:playerItem];
                [self addObserver];//添加监听事件
                [self resetPlay];//从头开始播放
            }
        }
    }
}

/**
 @功能说明：后一首 按钮按下回调
 @参数说明：sender 当前按钮
 @返回值：无
 */
- (IBAction)nextClicked {
    if (self.urls && self.urls.count > 0) {
        self.currentIndex++;
        if (self.currentIndex >= self.urls.count-1) {
            self.currentIndex = (int)self.urls.count-1;
            NSLog(@"已经是最后一个音频了！");
        }
        
        if (self.player) {
            NSURL *url = nil;
            self.urlStr = self.urls[self.currentIndex];
            if ([self.urlStr hasPrefix:@"http"]) {//在线播放
                url = [NSURL URLWithString:[self.urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            } else {//本地播放
                NSString *file=[[NSBundle mainBundle] pathForResource:self.urlStr ofType:nil];
                url = [NSURL fileURLWithPath:file];
            }
            
            if (url) {
                [self.player pause];
                [self removeObserver];//首先移出播放监听事件
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                [self.player replaceCurrentItemWithPlayerItem:playerItem];
                [self addObserver];//添加监听事件
                [self resetPlay];//从头开始播放
            }
        }
    }
}

/**
 @功能说明：音量按钮值改变时，回调
 @参数说明：sender 当前滑块
 @返回值：无
 */
- (IBAction)volumSliderValueChanged:(UISlider *)sender {
    self.volum = sender.value;
    self.volumLab.text = [NSString stringWithFormat:@"%.1f", self.volum];
    if (self.player) {
        self.player.volume = self.volum;
    }
}

@end
