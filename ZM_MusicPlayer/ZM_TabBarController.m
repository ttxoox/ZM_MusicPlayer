//
//  ZM_TabBarController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/21.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_TabBarController.h"
#import "ZM_LocalViewController.h"
#import "ZM_NetViewController.h"
#import "ZM_NavigationController.h"
@interface ZM_TabBarController ()

@end

@implementation ZM_TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setVC];
}
-(void)setVC
{
    [self addOneViewControllerWith:[[ZM_NavigationController alloc] initWithRootViewController:[[ZM_LocalViewController alloc] init]] title:@"本地音乐" image:@"local" andSelectedImage:@"local_s"];
    
    [self addOneViewControllerWith:[[ZM_NavigationController alloc] initWithRootViewController:[[ZM_NetViewController alloc] init]] title:@"网络音乐" image:@"net" andSelectedImage:@"net_s"];
}
-(void)addOneViewControllerWith:(UIViewController *)vc title:(NSString *)title image:(NSString *)image andSelectedImage:(NSString *)selectedImage
{
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [UIImage imageNamed:image];
    vc.tabBarItem.selectedImage = [UIImage imageNamed:selectedImage];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:vc];
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
