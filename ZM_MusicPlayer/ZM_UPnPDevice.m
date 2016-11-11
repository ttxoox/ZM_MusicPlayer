//
//  ZM_UPnPDevice.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/7.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_UPnPDevice.h"

@implementation ZM_UPnPDevice
- (instancetype)init{
    self = [super init];
    if (self) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}
-(NSString *)getSearchFile
{
    NSString * searchFileSource = @"M-SEARCH * HTTP/1.1\r\nHOST: %@:%d\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: %@\r\nUSER-AGENT: iOS UPnP/1.1 TestApp/1.0\r\n\r\n";
    return [NSString stringWithFormat:searchFileSource,ssdpAddress,ssdpPort,serviceAVTransport];
}
-(void)searchDevices
{
    NSError * error;
    NSData * searchData = [[self getSearchFile] dataUsingEncoding:NSUTF8StringEncoding];
    [_udpSocket bindToPort:ssdpPort error:&error];
    [_udpSocket joinMulticastGroup:ssdpAddress error:&error];
    [_udpSocket sendData:searchData toHost:ssdpAddress port:ssdpPort withTimeout:0 tag:0];
    [_udpSocket beginReceiving:&error];
    if (error) {
        NSLog(@"%@",[error description]);
    }
}
#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"1");
    NSLog(@"%@",[[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding]);
    NSLog(@"%s",__func__);
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error
{
    NSLog(@"2");
    NSLog(@"%s",__func__);
    [self searchDevices];
    NSLog(@"%@",[error description]);
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"3");
    NSLog(@"%s",__func__);
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error
{
    NSLog(@"4");
    NSLog(@"%s",__func__);
    NSLog(@"%@",[error description]);
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext
{
    NSLog(@"5");
    //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSURL * location = [self getURLforDeviceWithData:data];
    if (location) {
        [self getInfoWithDeviceLocaltion:location];
    }
}

#pragma mark - 解析文件
-(NSURL *)getURLforDeviceWithData:(NSData *)data
{
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *subArray = [string componentsSeparatedByString:@"\n"];
    for (int j = 0 ; j < subArray.count; j++){
        //注意，此处分割时，用": "(冒号＋一个空格分隔)来分隔
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@": "];
        if ([dicArray[0] isEqualToString:@"LOCATION"] || [dicArray[0] isEqualToString:@"Location"]) {
            if (dicArray.count > 1) {
                NSString *location = dicArray[1];
                location = [location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSURL *url = [NSURL URLWithString:location];
                NSLog(@"设备地址:%@",url);
                return url;
            }
        }
    }
    return nil;
}

-(void)getInfoWithDeviceLocaltion:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest  *request=[NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(error || data == nil){
                NSLog(@"%@",[error description]);
            }else{
                ZM_UpnpModel *model = [[ZM_UpnpModel alloc] init];
                model.urlHeader = [NSString stringWithFormat:@"%@://%@:%@", [url scheme], [url host], [url port]];
                NSString *_dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:_dataStr options:0 error:nil];
                GDataXMLElement *xmlEle = [xmlDoc rootElement];
                NSArray *xmlArray = [xmlEle children];
                
                for (int i = 0; i < [xmlArray count]; i++) {
                    GDataXMLElement *element = [xmlArray objectAtIndex:i];
                    if ([[element name] isEqualToString:@"device"]) {
                        [model setArray:[element children]];
                        continue;
                    }
                }
                if (model.AVTransportServiceModel.controlURL) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.delegate respondsToSelector:@selector(searchDeviceWithModel:)]) {
                            [self.delegate searchDeviceWithModel:model];
                        }
                    });
                }
            }
        }];
        // 执行任务
        [dataTask resume];
    });
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error
{
    NSLog(@"6");
    NSLog(@"%s",__func__);
    NSLog(@"%@",[error description]);
    
}

@end
