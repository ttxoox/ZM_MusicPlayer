//
//  ZM_MusicManager.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_MusicManager.h"
static ZM_MusicManager * instance;
static AVAudioSession * session;

@interface ZM_MusicManager ()<AVAudioPlayerDelegate>

@end

@implementation ZM_MusicManager
//初始化单例类
+(ZM_MusicManager *)shareMusicManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        session = [AVAudioSession sharedInstance];
        //激活会话对象
        [session setActive:YES error:nil];
        //设置后台播放
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        _playList = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 播放音乐

 @param playURL 音乐源地址
 @param index   播放列表下标
 */
-(void)playMusicWithURL:(NSURL *)playURL andIndex:(NSInteger)index
{
    NSError * error;
    NSData * data = [NSData dataWithContentsOfURL:playURL];
    //此处建议使用initWithData方法，不建议下面的initWithContentsOfURL方法
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    //self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(error){
        NSLog(@"data初始化方式出现错误，错误详情:%@,进入URL初始化！",error);
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:playURL error:nil];
    }
    self.audioPlayer.delegate = self;
    if ([self.audioPlayer prepareToPlay]) {
        [self.audioPlayer play];
    }
}

/**
 暂停播放
 */
-(void)pausePlayMusic
{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
    }else{
        [self.audioPlayer play];
    }
}
-(CGFloat)getCurrentTime
{
    return self.audioPlayer.currentTime;
    
}
-(CGFloat)getTotalTime
{
    return self.audioPlayer.duration;
}
-(BOOL)isPlayingMusic
{
    return self.audioPlayer.playing;
}
-(void)stopPlayingMusic
{
    [self.audioPlayer stop];
}

/**
 下一首
 */
-(void)nextMusic
{
    _index ++;
    NSURL * nextURL;
    if (_index > self.playList.count - 1) {
        _index = 0;
    }
    NSString * string = [NSString stringWithFormat:@"%@",[self.playList[_index] url]];
    NSArray * array = [string componentsSeparatedByString:@":"];
    if ([array[0] isEqualToString:@"http"]) {
        //网络音乐
        nextURL  = [NSURL URLWithString:[NSString stringWithFormat:@"%@&ua=Iphone_Sst&version=4.239&netType=1&toneFlag=1",[self.playList[_index] url]]];
        
    }else{
        nextURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@",[_playList[_index] url]] withExtension:nil];
    }
    [self playMusicWithURL:nextURL andIndex:_index];
    
}

/**
 上一首
 */
-(void)previousMusic
{
    _index --;
    NSURL * nextURL;
    if (_index < 0) {
        _index = self.playList.count - 1;
    }
    NSString * string = [NSString stringWithFormat:@"%@",[self.playList[_index] url]];
    NSArray * array = [string componentsSeparatedByString:@":"];
    if ([array[0] isEqualToString:@"http"]) {
        //网络音乐
        nextURL  = [NSURL URLWithString:[NSString stringWithFormat:@"%@&ua=Iphone_Sst&version=4.239&netType=1&toneFlag=1",[self.playList[_index] url]]];
        
    }else{
        nextURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@",[_playList[_index] url]] withExtension:nil];
    }
    [self playMusicWithURL:nextURL andIndex:_index];

}
#pragma mark -AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //发送通知，告诉控制器音乐播放完了，切换下一首播放，也可以直接在这里播放下一首
    NSNotification * notification = [NSNotification notificationWithName:@"PLAYEND" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
}
@end
