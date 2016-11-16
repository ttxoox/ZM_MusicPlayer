//
//  ZM_DLNAViewController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/11/4.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_DLNAViewController.h"
#import "Header.h"
@interface ZM_DLNAViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView * tableView;


//@property (nonatomic, strong)ZM_UPnPDevice * upnp;

@end

@implementation ZM_DLNAViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.upnp searchDevices];
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}
-(void)setup
{
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KHEIGHT-110, KWIDTH, 110) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 30)];
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 30)];
    titleLabel.text = @"GVS提醒您选择DLNA设备:";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.textColor = [UIColor grayColor];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:titleLabel];
    
    return headerView;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = self.dataArray[indexPath.row];
    }else{
        ZM_UpnpModel * model = self.dataArray[indexPath.row];
        cell.textLabel.text = model.friendlyName;
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        ZM_UpnpModel * model = self.dataArray[indexPath.row];
        self.modelblock(model);
    }else{
        
        self.musicblock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)upnpModelBlock:(modelBlock)block
{
    self.modelblock = block;
}
-(void)musicBlockHandle:(musicBlock)block
{
    self.musicblock = block;
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
