//
//  ZM_PlayViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_PlayViewController.h"
#import "Header.h"
@interface ZM_PlayViewController ()
@property (nonatomic, strong)NSURL * url;
@property (weak, nonatomic) IBOutlet UIButton *previousBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *cureenTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, assign)BOOL fileIsExist;
@end
static ZM_PlayViewController * playVC;

@implementation ZM_PlayViewController
{
    NSTimer * _timer;
    NSArray * _array;
}
+(ZM_PlayViewController *)sharedPlayVC
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playVC = [[ZM_PlayViewController alloc] init];
    });
    return playVC;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
