//
//  ZM_NetViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/21.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_NetViewController.h"
#import "Header.h"
@interface ZM_NetViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property(nonatomic, strong)UITableView * tableView;
@property(nonatomic, strong)NSMutableArray * dataArray;//数据源
@property(nonatomic, strong)AFHTTPSessionManager * manager;//管理器
@end

@implementation ZM_NetViewController
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
    [self setup];
    
    [self loadDataSource];
}
-(void)setup
{
    self.title = @"网络音乐";
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 50)];
    searchBar.delegate = self;
    searchBar.placeholder = @"查找歌手或歌曲";
    searchBar.showsCancelButton = YES;
    self.tableView.tableHeaderView = searchBar;
    [self.view addSubview:_tableView];
}
#pragma mark - 请求数据
-(void)loadDataSource
{
    __weak typeof(self)weakSelf = self;
    [self.manager GET:SingerURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * allArray = [responseObject objectForKey:@"categories"];
        NSMutableArray * oneArray = [NSMutableArray array];
        NSMutableArray * twoArray = [NSMutableArray array];
        NSMutableArray * threeArray = [NSMutableArray array];
        for (NSDictionary * dict in allArray) {
            ZM_CategoryModel * cateModel = [[ZM_CategoryModel alloc] init];
            [cateModel setValuesForKeysWithDictionary:dict];
            if ([cateModel.group isEqualToNumber:@1]) {
                [oneArray addObject:cateModel];
            }else if ([cateModel.group isEqualToNumber:@2]){
                [twoArray addObject:cateModel];
            }else{
                [threeArray addObject:cateModel];
            }
        }
        self.dataArray = [[NSMutableArray alloc] initWithObjects:oneArray,twoArray,threeArray, nil];
        [weakSelf.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}
#pragma mark - UITableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray[section] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    ZM_CategoryModel * model = _dataArray[indexPath.section][indexPath.row];
    cell.textLabel.text = model.title;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZM_CategoryModel * model = _dataArray[indexPath.section][indexPath.row];
    ZM_SingerListViewController * slvc = [[ZM_SingerListViewController alloc] init];
    slvc.url = model.url;
    slvc.pageName = model.title;
    [self.navigationController pushViewController:slvc animated:YES];
}

#pragma mark - searchBar delegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"该功能暂未实现" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
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
