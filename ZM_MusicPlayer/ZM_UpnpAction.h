//
//  ZM_UpnpAction.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/9.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, UpnpServiceType){
    ZMAVTransportService,  // @"urn:schemas-upnp-org:service:AVTransport:1"
    ZMRenderControlService,  //@"urn:schemas-upnp-org:service:RenderingControl:1"
};

@class ZM_UpnpModel;
@interface ZM_UpnpAction : NSObject

@property(nonatomic, assign)UpnpServiceType serviceType;
@property(nonatomic, copy)NSString * name;

-(instancetype)initWithAction:(NSString *)action;

- (void)setArgumentValue:(NSString *)value forName:(NSString *)name;

- (NSString *)getServiceType;

- (NSString *)getSOAPAction;

- (NSString *)getPostUrlStrWith:(ZM_UpnpModel *)model;

- (NSString *)getPostXMLFile;

@end
