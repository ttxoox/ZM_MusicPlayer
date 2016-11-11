//
//  ZM_UpnpModel.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/7.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <Foundation/Foundation.h>

//服务端model
//保存设备的信息，可以从xml文件里面看到
@interface ZM_ServiceModel : NSObject

@property (nonatomic, copy) NSString *serviceType;
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *controlURL;
@property (nonatomic, copy) NSString *eventSubURL;
@property (nonatomic, copy) NSString *SCPDURL;

- (void)setArray:(NSArray *)array;

@end

@interface ZM_UpnpModel : NSObject

@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *modelName;

@property (nonatomic, copy) NSString *urlHeader;

@property (nonatomic, strong) ZM_ServiceModel *AVTransportServiceModel;
@property (nonatomic, strong) ZM_ServiceModel *RenderControlServiceModel;

- (void)setArray:(NSArray *)array;

@end
