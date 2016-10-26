//
//  ZM_PlayViewController.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZM_MusicModel.h"

@interface ZM_PlayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backImgView;
@property (weak, nonatomic) IBOutlet UILabel *musicName;
@property (weak, nonatomic) IBOutlet UILabel *singerName;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property(nonatomic, strong)NSMutableArray<ZM_MusicModel *> * musicArray;//播放列表
@property(nonatomic, assign)NSInteger playItem;//数组下标
@end
