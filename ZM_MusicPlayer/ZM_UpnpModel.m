//
//  ZM_UpnpModel.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/7.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_UpnpModel.h"
#import "GDataXMLNode.h"
#import "Header.h"
@implementation ZM_ServiceModel
- (void)setArray:(NSArray *)array{
    for (int m = 0; m < array.count; m++) {
        GDataXMLElement *needEle = [array objectAtIndex:m];
        if ([needEle.name isEqualToString:@"serviceType"]) {
            self.serviceType = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"serviceId"]) {
            self.serviceId = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"controlURL"]) {
            self.controlURL = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"eventSubURL"]) {
            self.eventSubURL = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"SCPDURL"]) {
            self.SCPDURL = [needEle stringValue];
        }
    }
}

@end

@implementation ZM_UpnpModel
- (instancetype)init{
    self = [super init];
    if (self) {
        self.AVTransportServiceModel = [[ZM_ServiceModel alloc] init];
        self.RenderControlServiceModel = [[ZM_ServiceModel alloc] init];
    }
    return self;
}

- (void)setArray:(NSArray *)array{
    for (int j = 0; j < [array count]; j++) {
        GDataXMLElement *ele = [array objectAtIndex:j];
        if ([ele.name isEqualToString:@"friendlyName"]) {
            self.friendlyName = [ele stringValue];
        }
        if ([ele.name isEqualToString:@"modelName"]) {
            self.modelName = [ele stringValue];
        }
        if ([ele.name isEqualToString:@"serviceList"]) {
            NSArray *serviceListArray = [ele children];
            for (int k = 0; k < [serviceListArray count]; k++) {
                GDataXMLElement *listEle = [serviceListArray objectAtIndex:k];
                if ([listEle.name isEqualToString:@"service"]) {
                    if ([[listEle stringValue] rangeOfString:serviceAVTransport].location != NSNotFound) {
                        [self.AVTransportServiceModel setArray:[listEle children]];
                    }else if ([[listEle stringValue] rangeOfString:serviceRenderControl].location != NSNotFound){
                        [self.RenderControlServiceModel setArray:[listEle children]];
                    }
                }
            }
            continue;
        }
    }
}

@end
