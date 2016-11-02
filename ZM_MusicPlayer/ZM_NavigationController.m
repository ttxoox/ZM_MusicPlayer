//
//  ZM_NavigationController.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/21.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_NavigationController.h"
#import "ZM_PlayViewController.h"
#import "ZM_NetViewController.h"
@interface ZM_NavigationController ()

@end

@implementation ZM_NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    if (![viewController.class isSubclassOfClass:[ZM_NetViewController class]]) {
        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"playing"] style:UIBarButtonItemStylePlain target:self action:@selector(toPlayPage)];
    }
    
    [super pushViewController:viewController animated:animated];
}
-(void)back
{
    [self popViewControllerAnimated:YES];
}
-(void)toPlayPage
{
#if 0
    [self presentViewController:[ZM_PlayViewController sharedPlayVC] animated:YES completion:^{
        NSNotification * notification = [NSNotification notificationWithName:@"TOPLAYPAGE" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
#endif
     
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
