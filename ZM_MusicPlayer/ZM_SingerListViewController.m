//
//  ZM_SingerListViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/24.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_SingerListViewController.h"
#import "Header.h"
@interface ZM_SingerListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView * tableView;
@property(nonatomic, strong)NSMutableArray<ZM_SingerListModel *> * dataArray;
@property(nonatomic, strong)AFHTTPSessionManager * manager;
@property(nonatomic, assign)NSInteger page;//当前页
@property(nonatomic, copy)NSString * pageCount;//总页数
@end

@implementation ZM_SingerListViewController
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
    [self setupTabelView];
    [self loadDataSource];
}
-(void)setupTabelView
{
    self.title = self.pageName;
    self.page = 1;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, KHEIGHT) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataSource)];
    [self.tableView.mj_footer beginRefreshing];
    [self.view addSubview:_tableView];
}
-(void)loadDataSource
{
    NSString * url = [self.url stringByAppendingString:DetailURL];
    __weak typeof(self)weakSelf = self;
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    [self.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        weakSelf.pageCount = responseObject[@"pagecount"];
        weakSelf.dataArray = [ZM_SingerListModel mj_objectArrayWithKeyValuesArray:responseObject[@"singers"]];
        [weakSelf.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ;
    }];
}
-(void)loadMoreDataSource
{
    self.page+=1;
    if (_page <= [self.pageCount integerValue]) {
        NSString * urlStr = [DetailURL stringByReplacingOccurrencesOfString:@"pageno=1" withString:[NSString stringWithFormat:@"pageno=%ld",_page]];
        self.url = [self.url stringByAppendingString:urlStr];
    }
    __weak typeof(self)WeakSelf = self;
    [self.manager GET:self.url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //第三方，字典转模型
        NSArray<ZM_SingerListModel *> * listArray = [ZM_SingerListModel mj_objectArrayWithKeyValuesArray:responseObject[@"singers"]];
        [WeakSelf.dataArray addObjectsFromArray:listArray];
        [WeakSelf.tableView reloadData];
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
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    ZM_SingerListModel * model = _dataArray[indexPath.row];
    cell.textLabel.text = model.singer;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@"default_icon"]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZM_SingerListModel * model = self.dataArray[indexPath.row];
    ZM_SongViewController * svc = [[ZM_SongViewController alloc] init];
    svc.singerName = model.singer;
    svc.singerid = model.singerid;
    [self.navigationController pushViewController:svc animated:YES];
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
