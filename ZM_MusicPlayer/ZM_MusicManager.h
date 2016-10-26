//
//  ZM_MusicManager.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface ZM_MusicManager : NSObject
@property (nonatomic, strong)AVAudioPlayer * audioPlayer;
@property (nonatomic, strong)AVPlayer * player;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, strong)NSMutableArray * playList;


/**
 单例类，音乐管理器

 @return 音乐管理器
 */
+(ZM_MusicManager *)shareMusicManager;

/**
 播放音乐

 @param url   传入音乐源地址
 @param index 音乐源下标
 */
-(void)playMusicWithURL:(NSURL *)url andIndex:(NSInteger)index;


/**
 暂停音乐播放
 */
-(void)pausePlayMusic;


/**
 获取当前播放时间

 @return 返回当前播放时间
 */
-(CGFloat)getCurrentTime;


/**
 获取总时间

 @return 返回总时间
 */
-(CGFloat)getTotalTime;


/**
 是否正在播放音乐

 @return 返回结果
 */
-(BOOL)isPlayingMusic;


/**
 停止播放音乐
 */
-(void)stopPlayingMusic;


/**
 下一首
 */
-(void)nextMusic;


/**
 上一首
 */
-(void)previousMusic;
@end
