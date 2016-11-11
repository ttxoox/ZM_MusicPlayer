//
//  ZM_PlayViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_PlayViewController.h"
#import "Header.h"
//#include <Platinum/PltUPnP.h>
#include <Platinum/Platinum.h>
#include <Neptune/Neptune.h>
@interface ZM_PlayViewController ()<ZM_UPnPSearchDelegate,ZM_RenderResponseDelegate>
@property (nonatomic, strong)NSURL * url;
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
+(ZM_PlayViewController *)sharedPlayVC
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playVC = [[ZM_PlayViewController alloc] init];
    });
    return playVC;
    
}
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
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
    
    //接收通知，该通知由ZM_NavigationController发送，更改当前页面的参数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setup) name:@"TOPLAYPAGE" object:nil];
    [self setup];
    [self startPlayMusic];
    [self startSearch];
    
}
-(void)setup
{
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
    [self.render play];
}
#pragma mark - ZM_UPnPSearchDelegate
-(void)searchDeviceWithModel:(ZM_UpnpModel *)model
{
    if (model) {
        self.dlnaBtn.hidden = NO;
    }
    if (self.dataArray.count == 0) {
        [self.dataArray addObject:model];
    }else{
        for (int i=0; i<self.dataArray.count; i++) {
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
    [[ZM_MusicManager shareMusicManager] previousMusic];
}
- (IBAction)playBtnHandle:(UIButton *)sender {
    self.playBtn.selected = !self.playBtn.isSelected;
    if (self.playBtn.isSelected) {
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [[ZM_MusicManager shareMusicManager] pausePlayMusic];
    }else{
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [[ZM_MusicManager shareMusicManager] pausePlayMusic];
    }
}
- (IBAction)nextBtnHandle:(UIButton *)sender {
    self.playItem++;
    [[ZM_MusicManager shareMusicManager] stopPlayingMusic];
    if (self.playItem > self.musicArray.count - 1) {
        self.playItem = 0;
    }
    [self setup];
    [[ZM_MusicManager shareMusicManager] nextMusic];
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
    self.definesPresentationContext = YES;
    dlna.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [dlna.dataArray addObjectsFromArray:self.dataArray];
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
-(void)getAVTransportURIResponse:(ZM_GetTransportInfoModel *)info
{
    NSLog(@"已捕获播放uri响应");
    NSLog(@"currentSpeed:%@",info.currentSpeed);
    NSLog(@"currentTransportState:%@",info.currentTransportState);
    NSLog(@"currentTransportStatus:%@",info.currentTransportStatus);
    /*
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [self.render play];
    }
     */
    [self playBtnHandle:self.playBtn];
    if (![info.currentTransportState isEqualToString:@"TRANSITIONNING"]) {
        [self.render play];
    }
    //[self.render play];
    
}
-(void)playActionResponse
{
    NSLog(@"播放动作响应");
}
-(void)pauseActionResponse
{
    NSLog(@"暂停动作响应");
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
