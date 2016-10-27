//
//  ZM_SearchViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/26.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_SearchViewController.h"
#import "Header.h"
@interface ZM_SearchViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView * tableView;
@property(nonatomic, strong)NSMutableArray<ZM_MusicModel *> * dataArray;
@property(nonatomic, strong)AFHTTPSessionManager * manager;
@property(nonatomic, assign)NSInteger page;
@end

@implementation ZM_SearchViewController
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, KHEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadDataSource)];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
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
    self.view.backgroundColor = [UIColor whiteColor];
    _page = 1;
    [self setup];
    [self loadDataSource];
}
-(void)setup
{
    UIView * tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 40)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 40)];
    label.text = [NSString stringWithFormat:@"通过%@为您找到以下信息",_searchText];
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13.0f];
    tabView.backgroundColor = [UIColor orangeColor];
    [tabView addSubview:label];
    self.tableView.tableHeaderView = tabView;
    
    self.navigationItem.title = self.searchText;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)loadDataSource
{
    NSString * pageStr = [NSString stringWithFormat:@"%ld",_page];
    NSDictionary * params = @{
                              @"pageno":pageStr,
                              @"title":self.searchText
                              };
    __weak typeof(self)WeakSelf = self;
    
    [self.manager GET:SearchURL parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray<ZM_MusicModel *> * array = [ZM_MusicModel mj_objectArrayWithKeyValuesArray:responseObject[@"songs"]];
        [WeakSelf.dataArray addObjectsFromArray:array];
        [WeakSelf.tableView.mj_footer endRefreshing];
        [WeakSelf.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ;
    }];
    self.page += 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZM_MusicTVCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ZM_MusicTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    [cell creatCellWithModel:self.dataArray[indexPath.row]];
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
