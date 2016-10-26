//
//  ViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/21.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_LocalViewController.h"
#import "Header.h"
@interface ZM_LocalViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView * tableView;
@property(nonatomic, strong)NSMutableArray * dataArray;
@end

@implementation ZM_LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setup];
    self.title = @"本地音乐";
}
//懒加载，第三方库完成字典转模型
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] initWithArray:[ZM_MusicModel mj_objectArrayWithFile:PlistPath]];
    }
    return _dataArray;
}

-(void)setup
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, KHEIGHT) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZM_MusicTVCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[ZM_MusicTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    ZM_MusicModel * model = self.dataArray[indexPath.row];
    [cell creatCellWithModel:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [ZM_MusicManager shareMusicManager].playList = self.dataArray;
    [ZM_MusicManager shareMusicManager].index = indexPath.row;
    ZM_PlayViewController * pvc = [[ZM_PlayViewController alloc] initWithNibName:@"ZM_PlayViewController" bundle:nil];
    pvc.musicArray = self.dataArray;
    pvc.playItem = indexPath.row;
    [self presentViewController:pvc animated:YES completion:nil];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
