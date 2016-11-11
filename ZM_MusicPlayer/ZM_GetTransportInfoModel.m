//
//  ZM_GetTransportInfoModel.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/9.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_GetTransportInfoModel.h"
#import "GDataXMLNode.h"
@implementation ZM_GetTransportInfoModel
-(void)setArray:(NSArray *)array
{
    for (int m = 0; m < array.count; m++) {
        GDataXMLElement *needEle = [array objectAtIndex:m];
        if ([needEle.name isEqualToString:@"CurrentTransportState"]) {
            self.currentTransportState = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"CurrentTransportStatus"]) {
            self.currentTransportStatus = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"CurrentSpeed"]) {
            self.currentSpeed = [needEle stringValue];
        }
    }

}
@end
