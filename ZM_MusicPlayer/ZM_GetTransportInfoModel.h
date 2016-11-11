//
//  ZM_GetTransportInfoModel.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/9.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ZM_GetTransportInfoModel : NSObject
@property(nonatomic, copy)NSString * currentTransportState;
@property(nonatomic, copy)NSString * currentTransportStatus;
@property(nonatomic, copy)NSString * currentSpeed;
-(void)setArray:(NSArray *)array;
@end
