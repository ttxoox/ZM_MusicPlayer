//
//  ZM_DMRender.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/8.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZM_GetTransportInfoModel;
@protocol ZM_RenderResponseDelegate <NSObject>
@optional
-(void)setAVTransportURIResponse;
-(void)setNextTransportURIResponse;
-(void)getAVTransportURIResponse:(ZM_GetTransportInfoModel *)info;
-(void)playActionResponse;
-(void)pauseActionResponse;
-(void)stopActionResponse;
-(void)nextActionResponse;
-(void)previousActionResponse;
-(void)setVolumeResponse;
-(void)getVolumeResponseWithVolume:(NSString *)volume;
-(void)undefineActionResponse:(NSString *)xmlString;

@end
@class ZM_UpnpModel;
@interface ZM_Render : NSObject
@property(nonatomic, strong)ZM_UpnpModel * model;
@property(nonatomic, strong)id<ZM_RenderResponseDelegate>delegate;

-(instancetype)initWithModel:(ZM_UpnpModel *)model;

/**
 设置投屏链接

 @param urlStr 链接地址
 */
-(void)setAVTransportWithURL:(NSString *)urlStr;

/**
 设置下一个投屏链接

 @param urlStr 链接地址
 */
-(void)setNextAVTransportWithNextURL:(NSString *)urlStr;
/**
 播放
 */
-(void)play;

/**
 暂停
 */
-(void)pause;

/**
 停止
 */
-(void)stop;


/**
 下一首
 */
-(void)next;

/**
 上一首
 */
-(void)previous;


/**
 设置音量

 @param volStr 用NSString类型的数据（@“23”）
 */
-(void)setVolumeWithString:(NSString *)volStr;


/**
 获取音量
 */
-(void)getVolume;


/**
 获取播放信息
 */
-(void)getTransportInfo;
@end
