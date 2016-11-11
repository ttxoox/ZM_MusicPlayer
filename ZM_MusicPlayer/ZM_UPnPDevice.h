//
//  ZM_UPnPDevice.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/7.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"

@protocol ZM_UPnPSearchDelegate <NSObject>

@required
-(void)searchDeviceWithModel:(ZM_UpnpModel *)model;

@optional
-(void)searchDeviceWithError:(NSError *)error;

@end
@interface ZM_UPnPDevice : NSObject<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket * _udpSocket;
}
@property (nonatomic, strong)id<ZM_UPnPSearchDelegate>delegate;
-(void)searchDevices;
@end
