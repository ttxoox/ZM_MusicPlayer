//
//  ZM_PlayViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_PlayViewController.h"
#import "Header.h"
#import <MediaPlayer/MediaPlayer.h>
@interface ZM_PlayViewController ()<ZM_UPnPSearchDelegate,ZM_RenderResponseDelegate>
@property (nonatomic, strong)NSURL * url;
@property (nonatomic, copy)NSString * nextURLStr;
@property (weak, nonatomic) IBOutlet UIButton *previousBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *cureenTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *dlnaBtn;

@property (nonatomic, assign)BOOL fileIsExist;

@property (nonatomic, strong)ZM_UPnPDevice * upnpDevice;
@property (nonatomic, strong)NSMutableArray * dataArray;//Device
//@property (nonatomic, strong)ZM_UpnpModel * upnpModel;
@property (nonatomic, strong)ZM_Render * render;
@end
static ZM_PlayViewController * playVC;

@implementation ZM_PlayViewController
{
    NSTimer * _timer;
    NSArray * _array;
    NSInteger vol;//设备反馈的声音
    
}
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] initWithObjects:[[UIDevice currentDevice] name], nil];
    }
    return _dataArray;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dlnaBtn.hidden = YES;
    [_timer setFireDate:[NSDate distantPast]];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self startPlayMusic];
}
-(NSMutableArray *)musicArray
{
    if (!_musicArray) {
        _musicArray = [[NSMutableArray alloc] init];
    }
    return _musicArray;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_timer setFireDate:[NSDate distantFuture]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //接收通知，该通知由ZM_MusicManager发送,当前歌曲播放完毕，进行下一首播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextBtnHandle:) name:@"PLAYEND" object:nil];
    
    //监听系统音量的变化，通知名不可改
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSystemVolume:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self setup];
    [self startPlayMusic];
    [self startSearch];
    
    
}
-(void)setSystemVolume:(NSNotification *)notification
{
    float systemVolume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (self.render != nil) {
        [self.render setVolumeWithString:[NSString stringWithFormat:@"%d",(int)(systemVolume*100)]];
    }
}
-(void)setup
{
    //NSLog(@"%@",[[UIDevice currentDevice] name]);
    self.musicName.text = [NSString stringWithFormat:@"%@-%@专辑",[self.musicArray[_playItem] title],[self.musicArray[_playItem] album]];
    self.singerName.text = [self.musicArray[_playItem] singer];
    _array = [[self.musicArray[_playItem] singerImg] componentsSeparatedByString:@":"];
    if ([_array[0] isEqualToString:@"http"]) {
        //网络封面图片
        [self.backImgView sd_setImageWithURL:[NSURL URLWithString:[self.musicArray[_playItem] singerImg]]];
    }else if ([[self.musicArray[_playItem] singerImg] isEqualToString:@"无"] || [self.musicArray[_playItem] singerImg].length == 0) {
        self.backImgView.image = [UIImage imageNamed:@"default_play_bg.jpg"];
    }else{
        self.backImgView.image = [UIImage imageNamed:[self.musicArray[_playItem] singerImg]];
    }
    if ([_array[0] isEqualToString:@"http"]) {
        //网络音乐源
        NSString * urlStr = [NSString stringWithFormat:@"%@&ua=Iphone_Sst&version=4.239&netType=1&toneFlag=1",[self.musicArray[_playItem] url]];
        self.url = [NSURL URLWithString:urlStr];
        self.nextURLStr = [NSString stringWithFormat:@"%@&ua=Iphone_Sst&version=4.239&netType=1&toneFlag=1",[self.musicArray[_playItem+1] url]];
    }else{
        self.url = [[NSBundle mainBundle] URLForResource:[self.musicArray[_playItem] url] withExtension:nil];
    }
    self.playBtn.selected = YES;
    if ([[self.musicArray[_playItem] url] length] == 0) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"应版权方要求，该歌曲暂时不能播放，已自动切换到下一首歌曲。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
         
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:^{
            [self nextBtnHandle:self.nextBtn];
        }];
        
        //plist文件:瓦解音乐源:255319.mp3
       // [self nextBtnHandle:self.nextBtn];
    }
    
}
#pragma mark - 搜索UPnP设备
//在这个页面搜索，然后传到ZM_DLNAViewController里面，在ZM_DLNAViewController选择后block回调过来进行DLNA连接，目的是分离代码，便于维护。
//推送歌曲流程：
//1.搜索设备，[self startSearch]-->[ZM_UPnPDevice searchDevices],然后GCDAsyncUdpSocket发送广播包。搜索是不需要连接的，直接发包进行搜索。搜索到设备后会响应协议代理，返回控制器。[self searchDeviceWithModel:],把设备model存到数组。
//2.选择回调中的设备，进行控制。[self setDeviceWithModel:];
//3.控制。

-(void)startSearch
{
    self.upnpDevice = [[ZM_UPnPDevice alloc] init];
    self.upnpDevice.delegate = self;
    [self.upnpDevice searchDevices];
}
-(void)setDeviceWithModel:(ZM_UpnpModel *)model
{
    vol = 0;
    self.render = [[ZM_Render alloc] initWithModel:model];
    self.render.delegate = self;
    [self.render setAVTransportWithURL:[NSString stringWithFormat:@"%@",self.url]];
    //[self.render setAVTransportWithURL:@"http://sc1.111ttt.com/2016/1/11/14/204142307072.mp3"];
    //http://sc1.111ttt.com/2016/1/11/14/204142307072.mp3
    //http://up.haoduoge.com:82/mp3/2016-07-22/1469188914.mp3
    [self.render setNextAVTransportWithNextURL:self.nextURLStr];
    [self.render play];
}
//http://tyst.migu.cn/public/ringmaker01/n16/2016/10/2014年12月26日紧急准入纵横世代10首/全曲试听/Mp3_128_44_16/天涯过客-周杰伦.mp3?channelid=03&k=d33a28c679acd5c2&t=1479201093
//http://tyst.migu.cn/public/600907/tone/2014/12/16/2014121618/update/算什么男人-周杰伦/999989/算什么男人-周杰伦.mp3?channelid=03&k=5ea2f5b4b6549760&t=1479201213
#pragma mark - ZM_UPnPSearchDelegate
-(void)searchDeviceWithModel:(ZM_UpnpModel *)model
{
    if (model) {
        self.dlnaBtn.hidden = NO;
    }
    if (self.dataArray.count == 1) {
        [self.dataArray addObject:model];
    }else{
        for (int i=1; i<self.dataArray.count; i++) {
            NSString * name = [self.dataArray[i] friendlyName];
            if (![model.friendlyName isEqualToString:name]) {
                [self.dataArray addObject:model];
            }
        }
    }
}
-(void)searchDeviceWithError:(NSError *)error
{
    NSLog(@"search Device Error:%@",[error description]);
}

#pragma mark - xib方法
-(void)startPlayMusic
{
    _timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(sliderHandle:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [[ZM_MusicManager shareMusicManager] playMusicWithURL:self.url andIndex:_playItem];
}

- (IBAction)quitBtnHandle:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)previousBtnHandle:(UIButton *)sender {
    self.playItem--;
    [[ZM_MusicManager shareMusicManager] stopPlayingMusic];
    if (self.playItem < 0) {
        self.playItem = self.musicArray.count - 1;
    }
    [self setup];
    if (self.render == nil) {
        [[ZM_MusicManager shareMusicManager] previousMusic];
    }else{
        [self.render previous];
    }
    
    
}
- (IBAction)playBtnHandle:(UIButton *)sender {
    self.playBtn.selected = !self.playBtn.isSelected;
    if (self.render == nil) {
        if (self.playBtn.isSelected) {
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        }else{
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
        [[ZM_MusicManager shareMusicManager] pausePlayMusic];
    }else{
        if (self.playBtn.isSelected) {
            [self.render play];
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        }else{
            [self.render pause];
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
    }
}
- (IBAction)nextBtnHandle:(UIButton *)sender {
    self.playItem++;
    [[ZM_MusicManager shareMusicManager] stopPlayingMusic];
    if (self.playItem > self.musicArray.count - 1) {
        self.playItem = 0;
    }
    [self setup];
    if (self.render == nil) {
        [[ZM_MusicManager shareMusicManager] nextMusic];
    }else{
        
        self.nextURLStr = [NSString stringWithFormat:@"%@&ua=Iphone_Sst&version=4.239&netType=1&toneFlag=1",[self.musicArray[_playItem] url]];
        //[self.render setAVTransportWithURL:[NSString stringWithFormat:@"%@&ua=Iphone_Sst&version=4.239&netType=1&toneFlag=1",[self.musicArray[_playItem] url]]];
        [self.render setNextAVTransportWithNextURL:self.nextURLStr];
        [self.render next];
        
    }
}
- (IBAction)sliderHandle:(UISlider *)sender {
    CGFloat currentTime = [[ZM_MusicManager shareMusicManager] getCurrentTime];
    int currentM = (int)currentTime/60;
    int currentS = (int)currentTime%60;
    CGFloat totalTime = [[ZM_MusicManager shareMusicManager] getTotalTime];
    int totalM = (int)totalTime/60;
    int totalS = (int)totalTime%60;
    self.slider.maximumValue = totalM * 60 + totalS;
    NSString * currentString = [NSString stringWithFormat:@"%02d:%02d",currentM,currentS];
    NSString * totalString = [NSString stringWithFormat:@"%02d:%02d",totalM,totalS];
    self.cureenTimeLabel.text = currentString;
    self.totalTimeLabel.text = totalString;
    self.slider.value = currentM * 60 + currentS;
    
}
- (IBAction)downloadHandle:(UIButton *)sender {
    if (![self checkFileExist]) {
        [[ZM_MusicManager shareMusicManager] downloadMusicWithUrl:[NSString stringWithFormat:@"%@",self.url] andFileName:[self.musicArray[_playItem] title]];
    }
}
- (IBAction)dlnaHanle:(UIButton *)sender {
    ZM_DLNAViewController * dlna = [[ZM_DLNAViewController alloc] init];
    [dlna upnpModelBlock:^(ZM_UpnpModel *model) {
        [self setDeviceWithModel:model];
    }];
    [dlna musicBlockHandle:^() {
        [self.render stop];
        self.render = nil;
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [[ZM_MusicManager shareMusicManager] playMusicWithURL:self.url andIndex:_playItem];
    }];
    self.definesPresentationContext = YES;
    dlna.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [dlna.dataArray addObjectsFromArray:self.dataArray];
    dlna.render = self.render;
    [self presentViewController:dlna animated:YES completion:nil];
}
-(BOOL)checkFileExist
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * doc = [paths objectAtIndex:0];
    NSArray * listArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:doc error:nil];
    NSMutableArray * fileArray = [NSMutableArray array];
    for (NSString * str in listArray) {
        if ([[[str componentsSeparatedByString:@"."] lastObject] isEqualToString:@"mp3"]) {
            [fileArray addObject:str];
        }
    }
    for (NSString * name in fileArray) {
        if ([[[name componentsSeparatedByString:@"."] firstObject] isEqualToString:[self.musicArray[_playItem] title]]) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"歌曲已存在" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            self.fileIsExist = YES;
        }else{
            self.fileIsExist = NO;
        }
    }
    return self.fileIsExist;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - ZM_RenderResponseDelegate
-(void)setAVTransportURIResponse
{
    NSLog(@"播放uri设置响应成功");
}
-(void)setNextTransportURIResponse
{
    NSLog(@"设置下一首响应成功");
    [self.render play];
}
-(void)getAVTransportURIResponse:(ZM_GetTransportInfoModel *)info
{
    NSLog(@"已捕获播放uri响应");
    NSLog(@"currentSpeed:%@",info.currentSpeed);
    NSLog(@"currentTransportState:%@",info.currentTransportState);
    NSLog(@"currentTransportStatus:%@",info.currentTransportStatus);
    if (![info.currentTransportState isEqualToString:@"TRANSITIONNING"]) {
        [self.render play];
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [[[ZM_MusicManager shareMusicManager] audioPlayer] pause];
    }
}
-(void)playActionResponse
{
    NSLog(@"播放动作响应");
    //[self.playBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}
-(void)pauseActionResponse
{
    NSLog(@"暂停动作响应");
    //[self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}
-(void)stopActionResponse
{
    NSLog(@"停止动作响应");
}
-(void)nextActionResponse
{
    NSLog(@"下一首动作响应");
}
-(void)previousActionResponse
{
    NSLog(@"上一首动作响应");
}
-(void)setVolumeResponse
{
    NSLog(@"设置声音动作响应");
}
-(void)getVolumeResponseWithVolume:(NSString *)volume
{
    NSLog(@"获取声音动作响应");
    NSLog(@"%@",volume);
    
}
-(void)undefineActionResponse:(NSString *)xmlString
{
    NSLog(@"未定义的动作:%@",xmlString);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
