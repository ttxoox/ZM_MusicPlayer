//
//  ZM_MusicModel.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/21.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZM_MusicModel : NSObject
@property(nonatomic, copy)NSString * title;//歌名
@property(nonatomic, copy)NSString * album;//专辑名
@property(nonatomic, copy)NSString * singerIcon;//歌手头像
@property(nonatomic, copy)NSString * singerImg;//歌手封面
@property(nonatomic, copy)NSString * url;//歌曲源
@property(nonatomic, copy)NSString * singer;//歌手名

@end
