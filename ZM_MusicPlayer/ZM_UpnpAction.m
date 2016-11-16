//
//  ZM_UpnpAction.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/9.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_UpnpAction.h"
#import "Header.h"
@interface ZM_UpnpAction ()

@property(nonatomic, strong)GDataXMLElement * xmlElement;

@end

@implementation ZM_UpnpAction

-(instancetype)initWithAction:(NSString *)action
{
    self = [super init];
    if (self) {
        self.name = action;
        _serviceType = ZMAVTransportService;
        NSString * actionName = [NSString stringWithFormat:@"u:%@",action];
        self.xmlElement = [GDataXMLElement elementWithName:actionName];
    }
    return self;
}
-(void)setServiceType:(UpnpServiceType)serviceType
{
    _serviceType = serviceType;
}
-(void)setArgumentValue:(NSString *)value forName:(NSString *)name
{
    [self.xmlElement addChild:[GDataXMLElement elementWithName:name stringValue:value]];
}
-(NSString *)getServiceType
{
    if (_serviceType == ZMAVTransportService) {
        return serviceAVTransport;
    }else{
        return serviceRenderControl;
    }
}
-(NSString *)getSOAPAction
{
    //这里是拼接动作action，前面是服务，后面是动作，中间用#连接
    //urn:schemas-upnp-org:service:AVTransport:1#Play
    if (_serviceType == ZMAVTransportService) {
        return [NSString stringWithFormat:@"\"%@#%@\"",serviceAVTransport,self.name];
    }else{
        return [NSString stringWithFormat:@"\"%@#%@\"",serviceRenderControl,self.name];
    }
}
//拼接动作xml文件
-(NSString *)getPostXMLFile
{
    GDataXMLElement *xmlEle = [GDataXMLElement elementWithName:@"s:Envelope"];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"s:encodingStyle" stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:s" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"s:Body"];
    [self.xmlElement addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:[self getServiceType]]];
    [command addChild:self.xmlElement];
    [xmlEle addChild:command];
    return xmlEle.XMLString;
}
-(NSString *)getPostUrlStrWith:(ZM_UpnpModel *)model
{
    if (_serviceType == ZMAVTransportService) {
        return [self getUpnpURLwithModel:model.AVTransportServiceModel andHeader:model.urlHeader];
    }else{
        return [self getUpnpURLwithModel:model.RenderControlServiceModel andHeader:model.urlHeader];
    }
}
-(NSString *)getUpnpURLwithModel:(ZM_ServiceModel *)model andHeader:(NSString *)urlHeader
{
    //这里是对xml文件中的controlURL做处理，有的controlURL前面有反斜杠“／”，有的没有
    if ([[model.controlURL substringToIndex:1] isEqualToString:@"/"]) {
        return [NSString stringWithFormat:@"%@%@",urlHeader,model.controlURL];
    }else{
        return [NSString stringWithFormat:@"%@/%@",urlHeader,model.controlURL];
    }
}
@end
