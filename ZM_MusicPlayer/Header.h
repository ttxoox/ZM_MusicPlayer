//
//  Header.h
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/21.
//  Copyright © 2016年 GVS. All rights reserved.
//
/*
#ifdef _OBJC_GC_
#import "Platinum/Platinum.h"
#import "Neptune/Neptune.h"
#endif
*/



#ifndef Header_h
#define Header_h

#define KWIDTH self.view.frame.size.width
#define KHEIGHT self.view.frame.size.height
//plist文件路径
#define PlistPath [[NSBundle mainBundle] pathForResource:@"Musics.plist" ofType:nil]
//歌手列表
#define SingerURL @"http://a.vip.migu.cn/rdp2/test/v5.5/singer_categorys.do?ua=Iphone_Sst&version=4.2488"
//歌手列表拼接url
#define DetailURL @"&ua=Iphone_Sst&version=4.2000&pageno=1"

//搜索
#define SearchURL @"http://a.vip.migu.cn/rdp2/test/v5.5/search.do?ua=Iphone_Sst&version=4.2000&type=1"

//歌曲列表
#define SongListURL @"http://a.vip.migu.cn/rdp2/v5.5/singer_songs.do?ua=Iphone_Sst&version=4.239"

#import "AFNetWorking.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "GDataXMLNode.h"
#import "GCDAsyncUdpSocket.h"
//#import <Platinum/Platinum.h>


#import "ZM_TabBarController.h"
#import "ZM_NavigationController.h"
#import "ZM_LocalViewController.h"
#import "ZM_PlayViewController.h"
#import "ZM_NetViewController.h"
#import "ZM_SingerListViewController.h"
#import "ZM_SongViewController.h"
#import "ZM_SearchViewController.h"
#import "ZM_DLNAViewController.h"

#import "ZM_MusicModel.h"
#import "ZM_CategoryModel.h"
#import "ZM_SingerListModel.h"
#import "ZM_UpnpModel.h"
#import "ZM_UPnPDevice.h"
#import "ZM_Render.h"
#import "ZM_UpnpAction.h"
#import "ZM_GetTransportInfoModel.h"
#import "ZM_MusicTVCell.h"

#import "ZM_MusicManager.h"



/****************************test*******************/
#define SearchStr @"M-SEARCH * HTTP/1.1\r\nHOST: %@:%d\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: %@\r\nUSER-AGENT: iOS UPnP/1.1 TestApp/1.0\r\n\r\n"
#define ssdpAddress @"239.255.255.250"
#define ssdpPort 1900
static NSString *serviceAVTransport         = @"urn:schemas-upnp-org:service:AVTransport:1";
static NSString *serviceRenderControl       = @"urn:schemas-upnp-org:service:RenderingControl:1";

#endif /* Header_h */
