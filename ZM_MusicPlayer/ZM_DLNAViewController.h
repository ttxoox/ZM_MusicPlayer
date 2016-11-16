//
//  ZM_DLNAViewController.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/4.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZM_UpnpModel;
@class ZM_Render;
typedef void (^modelBlock)(ZM_UpnpModel *model);
typedef void (^musicBlock)();
@interface ZM_DLNAViewController : UIViewController

@property (nonatomic, strong)NSMutableArray * dataArray;
@property (nonatomic, strong)ZM_Render * render;

@property (nonatomic, strong)modelBlock modelblock;
@property (nonatomic, strong)musicBlock musicblock;
-(void)upnpModelBlock:(modelBlock)block;
-(void)musicBlockHandle:(musicBlock)block;
@end
