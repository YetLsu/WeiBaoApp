//
//  ChangePasswordController.m
//  XBS
//
//  Created by 刘毕涛 on 15/12/22.
//  Copyright © 2015年 刘毕涛. All rights reserved.
//

#import "ChangePasswordController.h"
#import "Utils.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
@interface ChangePasswordController ()
{
    MBProgressHUD *_hudView;
}
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *password1;
@property (weak, nonatomic) IBOutlet UITextField *password2;




@end

@implementation ChangePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    self.view.backgroundColor = KviewColor;
    
}
//验证
- (IBAction)verify:(UIButton *)sender {

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
