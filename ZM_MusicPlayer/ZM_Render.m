//
//  ZM_DMRender.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/8.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_Render.h"
#import "Header.h"
@implementation ZM_Render
-(instancetype)initWithModel:(ZM_UpnpModel *)model
{
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}
#pragma mark - AVTransportAction
-(void)setAVTransportWithURL:(NSString *)urlStr
{
    NSLog(@"urlStr:%@",urlStr);
    //设置动作及参数,具体有多少个参数，需要在XML文件里面看<argumentList>节点下有多少个子节点
    //动作名称:SetAVTransportURI,为特定值，在XML文件里可以体现
    //动作参数1:InstanceID,设置当前播放时期时为 0 即可
    //动作参数2:CurrentURI，设置为当前要投屏的URL
    //动作参数3:CurrentURIMetaData，媒体meta数据，可以为空
    ZM_UpnpAction * action = [[ZM_UpnpAction alloc] initWithAction:@"SetAVTransportURI"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:urlStr forName:@"CurrentURI"];
    [action setArgumentValue:@"" forName:@"CurrentURIMetaData"];
    [self postRequestWithAction:action];
}
-(void)getTransportInfo{
    ZM_UpnpAction *action = [[ZM_UpnpAction alloc] initWithAction:@"GetTransportInfo"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWithAction:action];
}

-(void)play
{
    ZM_UpnpAction * action = [[ZM_UpnpAction alloc] initWithAction:@"Play"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    //正常播放设置值为1
    [action setArgumentValue:@"1" forName:@"Speed"];
    [self postRequestWithAction:action];
}
-(void)pause
{
    ZM_UpnpAction * action = [[ZM_UpnpAction alloc] initWithAction:@"Pause"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWithAction:action];
}
-(void)stop
{
    ZM_UpnpAction * action = [[ZM_UpnpAction alloc] initWithAction:@"Stop"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWithAction:action];

}
-(void)next
{
    ZM_UpnpAction * action = [[ZM_UpnpAction alloc] initWithAction:@"Next"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWithAction:action];
}
-(void)previous
{
    ZM_UpnpAction * action = [[ZM_UpnpAction alloc] initWithAction:@"Previous"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWithAction:action];
}

#pragma mark - RenderControlAction
-(void)setVolumeWithString:(NSString *)volStr
{
    ZM_UpnpAction * action = [[ZM_UpnpAction alloc] initWithAction:@"SetVolume"];
    [action setServiceType:ZMRenderControlService];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [action setArgumentValue:volStr forName:@"DesiredVolume"];
    [self postRequestWithAction:action];
}
-(void)getVolume
{
    ZM_UpnpAction * action = [[ZM_UpnpAction alloc] initWithAction:@"getVolume"];
    [action setServiceType:ZMRenderControlService];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [self postRequestWithAction:action];
}
#pragma mark - Other Method
-(void)postRequestWithAction:(ZM_UpnpAction *)action
{
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:[action getPostUrlStrWith:_model]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:[NSString stringWithFormat:@"%@:%d",ssdpAddress,ssdpPort] forHTTPHeaderField:@"Host"];
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[action getSOAPAction] forHTTPHeaderField:@"SOAPACTION"];
    request.HTTPBody = [[action getPostXMLFile] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error||data==nil) {
            [self upnpUndefineWithErrorString:[action getPostXMLFile]];
        }else{
            [self parseResponseData:data];
        }
    }];
    [task resume];
}
-(void)parseResponseData:(NSData *)data
{
    GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement * rootElement = [doc rootElement];
    NSArray * array = [rootElement children];
    for (int i=0; i<array.count; i++) {
        GDataXMLElement * bodyElement = array[i];
        //NSLog(@"bodyElement:%@",bodyElement.XMLString);
        NSArray * bodyArray = [bodyElement children];
        if ([[bodyElement name] hasSuffix:@"Body"]) {
            [self respondsMethod:bodyArray];
        }else{
            [self upnpUndefineWithErrorString:rootElement.XMLString];
        }
    }
}
-(void)respondsMethod:(NSArray *)array
{
    for (int i=0; i<array.count; i++) {
        GDataXMLElement * element = array[i];
        if ([[element name] hasSuffix:@"SetAVTransportURIResponse"]) {
            [self upnpSetAVTransportResponse];
            [self getTransportInfo];
        }else if ([[element name] hasSuffix:@"PlayResponse"]){
            [self upnpPlayResponse];
        }else if ([[element name] hasSuffix:@"PauseResponse"]){
            [self upnpPauseResponse];
        }else if ([[element name] hasSuffix:@"StopResponse"]){
            [self upnpStopResponse];
        }else if ([[element name] hasSuffix:@"NextResponse"]){
            [self upnpNextResponse];
        }else if ([[element name] hasSuffix:@"PreviousResponse"]){
            [self upnpPreviousResponse];
        }else if ([[element name] hasSuffix:@"SetVolumeResponse"]){
            [self upnpSetVolumeResponse];
        }else if([[element name] hasSuffix:@"GetVolumeResponse"]){
            [self getVolumeSuccessWithInfo:element];
        }else if([[element name] hasSuffix:@"GetTransportInfoResponse"]){
            [self getTransportInfoResponseWithInfo:element];
        }else{
            [self upnpUndefineWithErrorString:element.XMLString];
        }
    }
}
#pragma mark - ResponseDelegate
-(void)upnpSetAVTransportResponse
{
    if ([self.delegate respondsToSelector:@selector(setAVTransportURIResponse)]) {
        [self.delegate setAVTransportURIResponse];
    }
}
-(void)upnpPlayResponse
{
    if ([self.delegate respondsToSelector:@selector(playActionResponse)]) {
        [self.delegate playActionResponse];
    }
}
-(void)upnpPauseResponse
{
    if ([self.delegate respondsToSelector:@selector(pauseActionResponse)]) {
        [self.delegate pauseActionResponse];
    }
}
-(void)upnpStopResponse
{
    if ([self.delegate respondsToSelector:@selector(stopActionResponse)]) {
        [self.delegate stopActionResponse];
    }
}
-(void)upnpNextResponse
{
    if ([self.delegate respondsToSelector:@selector(nextActionResponse)]) {
        [self.delegate nextActionResponse];
    }
}
-(void)upnpPreviousResponse
{
    if ([self.delegate respondsToSelector:@selector(previousActionResponse)]) {
        [self.delegate previousActionResponse];
    }
}
-(void)upnpSetVolumeResponse
{
    if ([self.delegate respondsToSelector:@selector(setVolumeResponse)]) {
        [self.delegate setVolumeResponse];
    }
}
-(void)upnpUndefineWithErrorString:(NSString *)xmlString
{
    if ([self.delegate respondsToSelector:@selector(undefineActionResponse:)]) {
        [self.delegate undefineActionResponse:xmlString];
    }
}
-(void)getVolumeSuccessWithInfo:(GDataXMLElement *)element
{
    NSArray * array = [element children];
    for (int i=0; i<array.count; i++) {
        GDataXMLElement * ele = [array objectAtIndex:i];
        if ([[ele name] isEqualToString:@"CurrentVolume"]) {
            if ([self.delegate respondsToSelector:@selector(getVolumeResponseWithVolume:)]) {
                [self.delegate getVolumeResponseWithVolume:[ele stringValue]];
            }
        }
    }
}
-(void)getTransportInfoResponseWithInfo:(GDataXMLElement *)element
{
    NSArray * array = [element children];
    ZM_GetTransportInfoModel *info = [[ZM_GetTransportInfoModel alloc] init];
    [info setArray:array];
    if ([self.delegate respondsToSelector:@selector(getAVTransportURIResponse:)]) {
        [self.delegate getAVTransportURIResponse:info];
    }

}

@end
