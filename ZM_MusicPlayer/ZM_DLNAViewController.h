//
//  ZM_DLNAViewController.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/4.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZM_UpnpModel;
typedef void (^modelBlock)(ZM_UpnpModel *model);
@interface ZM_DLNAViewController : UIViewController
@property (nonatomic, strong)NSMutableArray * dataArray;
@property (nonatomic, strong)modelBlock block;
-(void)upnpModelBlock:(modelBlock)block;
@end
