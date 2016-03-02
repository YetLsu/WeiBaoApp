//
//  MenuViewController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/18.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "MenuViewController.h"
#import "LeftViewController.h"
#import "CenterViewController.h"



@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.leftDrawerViewController = [[LeftViewController alloc]init];
    
    CenterViewController *centerVC = [[CenterViewController alloc]init];
    
    self.centerViewController = [[UINavigationController alloc]initWithRootViewController:centerVC];
    
    self.maximumLeftDrawerWidth = KscreenWidth*0.6;
    self.openDrawerGestureModeMask = MMOpenDrawerGestureModePanningNavigationBar;
    self.closeDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    

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
