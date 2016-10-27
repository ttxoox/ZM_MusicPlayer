//
//  ZM_SongViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_SongViewController.h"
#import "Header.h"
@interface ZM_SongViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView * tableView;
@property(nonatomic, strong)NSMutableArray<ZM_MusicModel *> * dataArray;//数据源
@property(nonatomic, strong)AFHTTPSessionManager * manager;
@property(nonatomic, assign)NSInteger page;
@property(nonatomic, copy)NSString * pageCount;
@end

@implementation ZM_SongViewController

//懒加载
-(NSMutableArray<ZM_MusicModel *> *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
-(AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTableView];
    [self loadDataSource];
    //清除播放列表的歌曲
    [[[ZM_MusicManager shareMusicManager] playList] removeAllObjects];
}
-(void)setupTableView
{
    self.title = self.singerName;
    self.page = 1;
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataSource)];
    
    /* 自定义刷新文字
    MJRefreshAutoGifFooter * footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataSource)];
    [footer setTitle:@"上拉刷新..." forState:MJRefreshStateIdle];
    [footer setTitle:@"刷新中..." forState:MJRefreshStateRefreshing];
    self.tableView.mj_footer = footer;
    [self.tableView.mj_footer beginRefreshing];
     */
    [self.view addSubview:_tableView];
    
}
-(void)loadDataSource
{
    
    __weak typeof(self)WeakSelf = self;
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    NSString * pageStr = [NSString stringWithFormat:@"%ld",self.page];
    NSDictionary * params = @{
                              @"pageno":pageStr,
                              @"singerid":self.singerid
                              };
    [self.manager GET:SongListURL parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        WeakSelf.dataArray = [ZM_MusicModel mj_objectArrayWithKeyValuesArray:responseObject[@"songs"]];
        [[[ZM_MusicManager shareMusicManager] playList] addObjectsFromArray:WeakSelf.dataArray];
        [WeakSelf.tableView reloadData];
        [WeakSelf.tableView.mj_footer endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [WeakSelf.tableView.mj_footer endRefreshing];
    }];
}
-(void)loadMoreDataSource
{
    self.page += 1;
    __weak typeof(self)WeakSelf = self;
    NSString * pageStr = [NSString stringWithFormat:@"%ld",self.page];
    NSDictionary * params = @{
                              @"pageno":pageStr,
                              @"singerid":self.singerid
                              };
    [self.manager GET:SongListURL parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@",downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray<ZM_MusicModel *> * array = [ZM_MusicModel mj_objectArrayWithKeyValuesArray:responseObject[@"songs"]];
        [WeakSelf.dataArray addObjectsFromArray:array];
        [WeakSelf.tableView reloadData];
        [[[ZM_MusicManager shareMusicManager] playList] addObjectsFromArray:array];
        [WeakSelf.tableView.mj_footer endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [WeakSelf.tableView.mj_footer endRefreshing];
        
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZM_MusicTVCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ZM_MusicTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    ZM_MusicModel * model = _dataArray[indexPath.row];
    [cell creatCellWithModel:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [ZM_MusicManager shareMusicManager].index = indexPath.row;
    [ZM_MusicManager shareMusicManager].playList = self.dataArray;
    ZM_PlayViewController * pvc = [[ZM_PlayViewController alloc] initWithNibName:@"ZM_PlayViewController" bundle:nil];
    //ZM_PlayViewController * pvc = [ZM_PlayViewController sharedPlayVC];
    pvc.musicArray = self.dataArray;
    pvc.playItem = indexPath.row;
    if ([[_dataArray[indexPath.row] url] length] == 0) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"应版权方要求，该歌曲暂时不能播放。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self presentViewController:pvc animated:YES completion:nil];
    }
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
