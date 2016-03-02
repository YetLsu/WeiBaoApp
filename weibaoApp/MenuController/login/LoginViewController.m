//
//  LoginViewController.m
//  XBS
//
//  Created by 刘毕涛 on 15/12/21.
//  Copyright © 2015年 刘毕涛. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterController.h"
#import "ChangePasswordController.h"
#import <AFNetworking.h>
#import <NSString+MD5.h>
#import "Utils.h"
#import <MBProgressHUD.h>
#import "Config.h"
#import "WBUser.h"
@interface LoginViewController ()<UIGestureRecognizerDelegate>
{
    MBProgressHUD *_hudView;
    
}
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *passWord;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登陆";
    self.view.backgroundColor = KviewColor;
    
//    _phone.returnKeyType = UIReturnKeyNext;
    
    _passWord.returnKeyType = UIReturnKeyDone;
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:gesture];
}
//确定这个手势是否可以实现
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //判断这个账号和密码控件中是否都是第一响应者
    if (![_phone isFirstResponder] && ![_passWord isFirstResponder]) {
        //都不是第一响应者的时候
        return NO;
    }
    return YES;
}

//隐藏键盘栏
- (void)hidenKeyboard
{
    [_phone resignFirstResponder];
    [_passWord resignFirstResponder];
}

//登录
- (IBAction)login:(UIButton *)sender {
    _hudView = [Utils createHUD];
    _hudView.userInteractionEnabled = NO;
    _hudView.labelText = @"正在登录";
    [_hudView hide:YES afterDelay:1];
    if ([Utils checkTelNumber:_phone.text]) {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSMutableDictionary *paramter = [Utils createParamterAct:Klogin Name:_phone.text Password:_passWord.text type:nil Message:nil];
    [manager POST:KurlString parameters:paramter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
       NSInteger isError = [responseObject[@"isError"] integerValue];
        if (!isError) {
            NSDictionary *dic = responseObject[@"result"];
            WBUser *user = [[WBUser alloc]initWithDic:dic];
            [Config saveProfile:user];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
            [self.navigationController popViewControllerAnimated:YES];
            return ;
        }
        _hudView.mode = MBProgressHUDModeCustomView;
        _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _hudView.labelText = responseObject[@"errorMessage"];
      
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@",error);
        _hudView.mode = MBProgressHUDModeCustomView;
        _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _hudView.labelText = @"网络异常，请检查网络";
    }];
    }
    else{
         _hudView.mode = MBProgressHUDModeCustomView;
        _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _hudView.labelText = @"输入的手机号码不合理";
    }   
}

//忘记密码
- (IBAction)changePassword:(UIButton *)sender {
    RegisterController *regietrVC = [[RegisterController alloc]init];
    regietrVC.type_r = @"2";
    regietrVC.title = @"忘记密码";
    regietrVC.act = KeditPwd;
    [self.navigationController pushViewController:regietrVC animated:YES];
}

//注册
- (IBAction)register:(UIButton *)sender {
    
    RegisterController *registerVC = [[RegisterController alloc]init];
    registerVC.type_r = @"1";
    registerVC.title = @"注册";
    registerVC.act = Kregister;
    [self.navigationController pushViewController:registerVC animated:YES];
    
    
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
