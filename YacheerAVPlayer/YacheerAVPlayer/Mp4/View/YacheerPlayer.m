//
//  YacheerPlayer.m
//  YacheerAVPlayer
//
//  Created by ChangWingchit on 2017/3/28.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "YacheerPlayer.h"

@implementation YacheerPlayer

#pragma mark - awakeFromNib 初始化xib文件上的子视图控件
/**
 @功能说明：初始化xib文件上的子视图控件，该方法是系统方法，用于初始化xib文件内容
 @参数说明：无
 @返回值：无
 */
- (void)awakeFromNib
{
    [super awakeFromNib];
    //设置xib的内容
    self.bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.currentIndex = 0;
    
    //添加加载提示
    [self activityIndicaorView:YES];
    
}

#pragma mark - Private Method
- (void)activityIndicaorView:(BOOL)show {
    if (show) {
        UIActivityIndicatorView *acView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        acView.center = self.containView.center;
        acView.tag = 6666;
        [self.containView addSubview:acView];
        [self bringSubviewToFront:acView];
        [acView startAnimating];
    } else {
        UIActivityIndicatorView *aView = [self viewWithTag:6666];
        [aView stopAnimating];
        [aView removeFromSuperview];
        aView = nil;
    }
}

#pragma mark - 开始播放
//播放一部视频
- (void)playerWithURLString:(NSString *)strURL
{
    self.urlStr = strURL;
    [self disableBottomView:NO];
    [self removeObserver];
    [self createPlayerLayer];
    [self addObserver];
}

//播放一组视频
- (void)playerWithURLs:(NSArray *)urls
{
    self.urls = urls;
    if (self.urls && [self.urls count]>0) {
        NSString *urlStr = self.urls[self.currentIndex];
        [self playerWithURLString:urlStr];
    }
}

#pragma mark - 创建播放器视图层
- (void)createPlayerLayer
{
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer]; //移出播放器层
        self.player = nil;
    }
    
    self.player = [self createPlayer];
    if (self.player) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];//创建播放层
        self.playerLayer.videoGravity = AVLayerVideoGravityResize; //视频填充模式
        [self.containView.layer addSublayer:self.playerLayer];
        self.containView.layer.masksToBounds = YES;//超出边界面截掉
        [self equalToFrame];//同步子视图的frame
        
        [self.containView bringSubviewToFront:self.bottomView];
        [self.containView bringSubviewToFront:self.acView];
    }
}

#pragma mark - 创建播放器，播放单个网络视频或本地视频
/**
 @功能说明：创建播放器，播放单个网络视频或本地视频
 @参数说明：无
 @返回值：当前播放器
 */
- (AVPlayer *)createPlayer
{
    if (self.player) {
        [self.player pause];
        self.player = nil;
    }
    if (self.urlStr && self.urlStr.length > 0) {
        NSURL *url = nil;
        if ([self.urlStr hasPrefix:@"http"]) { //网络资源
            url = [NSURL URLWithString:[self.urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }else{ //本地资源
            NSString *file = [[NSBundle mainBundle]pathForResource:self.urlStr ofType:nil];
            url = [NSURL fileURLWithPath:file];
        }
        
        if (url) {
            //[AVPlayer playerWithURL:url]
            AVPlayerItem *playItem = [AVPlayerItem playerItemWithURL:url];
            AVPlayer *player = [AVPlayer playerWithPlayerItem:playItem];
            return player;
        }
    }
    return nil;
}

#pragma mark - 网络视频未加载完成时，设置底部播放部分控件不可用
/**
 @功能说明：网络视频未加载完成时，设置底部播放栏部分控件不可用
 @参数说明：disable 是否可用
 @返回值：无
 */
- (void)disableBottomView:(BOOL)disable
{
    self.playOrPauseBtn.enabled = disable;
    self.prefixBtn.enabled = disable;
    self.nextBtn.enabled = disable;
    self.slider.enabled = disable;
    self.fullScreenBtn.enabled = disable;
}

#pragma mark - 移除AVPlayerItem的监听事件（移除播放结束监听,播放状态监听,加载网络监听,更新进度监听）
/**
 @功能说明：移除AVPlayerItem的监听事件（移除播放结束监听,播放状态监听,加载网络监听,更新进度监听）
 @参数说明：无
 @返回值：无
 */
- (void)removeObserver
{
    if (self.player) {
        AVPlayerItem *playItem = self.player.currentItem;
        [[NSNotificationCenter defaultCenter]removeObserver:self]; //移除播放结束监听
        [playItem removeObserver:self forKeyPath:@"status"];
        [playItem removeObserver:self forKeyPath:@"loadedTimeRanges"];//移出视频缓冲监听
        [self.player removeTimeObserver:self.observer];
    }
}

#pragma mark - 根据父视图来同步子视图的frame
/**
 @功能说明：根据父视图来同步子视图的frame
 @参数说明：无
 @返回值：无
 */
- (void)equalToFrame
{
    self.containView.frame = self.bounds;
    self.playerLayer.frame = self.containView.bounds;
    self.acView.center = self.containView.center;
}

#pragma mark - 给AVPlayerItem添加监听事件（播放结束监听，播放状态监听，视频缓存监听，播放进度监听）
/**
 @功能说明：给AVPlayerItem添加监听事件 (播放结束监听,播放状态监听,视频缓冲监听,播放进度监听)
 @参数说明：无
 @返回值：无
 */
- (void)addObserver
{
    if (self.player) {
        AVPlayerItem *playItem = self.player.currentItem;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil]; //播放结束监听
        [playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];    //监听播放状态属性
        [playItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil]; //监听缓冲属性
        [self addProgressObserver:playItem];  //监听进度属性
    }
}


#pragma mark - 播放完成通知
/**
 @功能说明：播放完成通知
 @参数说明：notification 通知对象
 @返回值：无
 */
- (void)playbackFinished
{
    NSLog(@"视频播放结束");
    AVPlayerItem *playerItem = self.player.currentItem;
    self.currentTimeLab.text = [self convertTime:CMTimeGetSeconds(playerItem.duration)];
    [self.slider setValue:1.0 animated:YES];
    [self.playOrPauseBtn setTitle:@"播放" forState:UIControlStateNormal];
}


#pragma mark - 给播放器添加更新进度监听,每秒监听一次
/**
 @功能说明：给播放器添加更新进度监听,每秒监听一次
 @参数说明：playerItem AVPlayerItem对象
 @返回值：无
 */
-(void)addProgressObserver:(AVPlayerItem*)playerItem
{
    //这里设置每秒执行一次
    __weak YacheerPlayer *weakSelf = self;
    self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
       float current = CMTimeGetSeconds(time);//当前时间（秒）
        if (current >= 0) {
            weakSelf.currentTimeLab.text = [weakSelf convertTime:current];
            //NSLog(@"当前已播放时长%@", weakSelf.currentTimeLab.text);
            if (weakSelf.duration > 0.0) {
                [weakSelf.slider setValue:current/weakSelf.duration animated:YES];
            }
        }
    }];
}

#pragma mark - 计算时间，返回字符串
/**
 @功能说明：计算时间，返回字符串
 @参数说明：播放秒数
 @返回值：返回秒数对应的字符串
 */
- (NSString*)convertTime:(CGFloat)second
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    if (second/36000 >= 1)  //大于一小时
    {
        int hour = second/3600;
        if (hour < 10) {
            [formatter setDateFormat:[NSString stringWithFormat:@"0%d:mm:ss",hour]];
        }
        else
        {
           [formatter setDateFormat:[NSString stringWithFormat:@"%d:mm:ss",hour]];
        }
    }
    else //小于一小时
    {
        [formatter setDateFormat:@"00:mm:ss"];
    }
    NSString *strTimer = [formatter stringFromDate:date];
    return strTimer;
}

#pragma mark - 播放或暂停
/**
 @功能说明：播放或暂停
 @参数说明：无
 @返回值：无
 */
- (IBAction)playOrPauseClicked {
    if(self.player.rate == 0){ //暂停
        [self.player play];
        [self.playOrPauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    }else if(self.player.rate == 1){//播放
        [self.player pause];
        [self.playOrPauseBtn setTitle:@"播放" forState:UIControlStateNormal];
    }
}

#pragma mark - 上一集
/**
 @功能说明：上一集
 @参数说明：无
 @返回值：无
 */
- (IBAction)prefixClicked {
    if (self.urls && self.urls.count > 0) {
        self.currentIndex--;
        if (self.currentIndex <= 0) {
            self.currentIndex = 0;
            NSLog(@"已经是第一个视频了！");
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
                [self playFromHeader];//从头开始播放
            }
        }
    }
}

#pragma mark - 下一集
/**
 @功能说明：下一集
 @参数说明：无
 @返回值：无
 */
- (IBAction)nextClicked {
    if (self.urls && self.urls.count > 0) {
        self.currentIndex++;
        if (self.currentIndex >= self.urls.count-1) {
            self.currentIndex = (int)self.urls.count-1;
            NSLog(@"已经是最后一个视频了！");
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
                [self playFromHeader];//从头开始播放
            }
        }
    }
}

#pragma mark - 全屏或退出全屏
/**
 @功能说明：全屏或退出全屏
 @参数说明：无
 @返回值：无
 */
- (IBAction)fullScreenClicked {
    if ([self.fullScreenBtn.currentTitle isEqualToString:@"全屏"]) {
        self.fs(YES);
        [self.fullScreenBtn setTitle:@"收缩" forState:UIControlStateNormal];
    } else {
        self.fs(NO);
        [self.fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
    }
}


#pragma mark - 从头开始播放
/**
 @功能说明：从头开始播放
 @参数说明：无
 @返回值：无
 */
- (void)playFromHeader {
    if (self.player) {
        [self.acView startAnimating];
        self.slider.value = 0.0;
        self.videoProgressView.progress = 0.0;
        [self.playOrPauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
        self.currentTimeLab.text = @"00:00:00";//重置当前播放时间
        [self.player seekToTime:CMTimeMakeWithSeconds(0, 1)];//设置视频为第一帧
        [self.player play];
    }
}

#pragma mark - 播放进度改变时调用
/**
 @功能说明：播放进度改变时调用
 @参数说明：无
 @返回值：无
 */
- (IBAction)sliderValueChanged:(id)sender {
    
    //这里需要暂停,防止造成拖动时进度条卡顿
    [self.player pause];
    
    AVPlayerItem *playerItem = self.player.currentItem;
    CGFloat value = self.slider.value;
    CGFloat duration = CMTimeGetSeconds(playerItem.duration);
    [self.player seekToTime:CMTimeMakeWithSeconds(value * duration, 1)];//从当前位置播放
}

#pragma mark - 托动播放时度停止时调用，因为托动时暂停了播放，所以等托动结束可恢复播放
/**
 @功能说明：托动播放时度停止时调用，因为托动时暂停了播放，所以等托动结束可恢复播放
 @参数说明：无
 @返回值：无
 */
- (IBAction)sliderValueEnd:(id)sender {
    
    [self.player play];
    [self.playOrPauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
}

#pragma mark - 通过KVO监控播放器状态
/**
 @功能说明：通过KVO监控播放器状态
 @参数说明：keyPath 监控的属性，object 监视的对象，change 状态改变，context 上下文
 @返回值：无
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self activityIndicaorView:NO];
    [self disableBottomView:YES];
    
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = playerItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            self.duration = CMTimeGetSeconds(playerItem.duration);
            self.totalTimeLab.text = [self convertTime:self.duration]; //显示总时长
            //NSLog(@"视频总时长%@", self.totalTimeLab.text);
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds+durationSeconds;//缓冲总长度
        float progress = totalBuffer/CMTimeGetSeconds(playerItem.duration);
        [self.videoProgressView setProgress:progress animated:YES];
        //NSLog(@"视频缓冲时长%@", [self convertTime:totalBuffer]);
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
