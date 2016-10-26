//
//  ZM_SingerListViewController.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZM_SingerListViewController : UIViewController

/**
 上一页面传过来的URL，歌手列表
 */
@property(nonatomic, copy)NSString * url;
@property(nonatomic, copy)NSString * pageName;//页面标题
@end
