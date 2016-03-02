//
//  RegisterController.m
//  XBS
//
//  Created by 刘毕涛 on 15/12/21.
//  Copyright © 2015年 刘毕涛. All rights reserved.
//

#import "RegisterController.h"
#import "Utils.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <NSString+MD5.h>



@interface RegisterController (){
    MBProgressHUD *_hudView;
}

@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *password1;
@property (weak, nonatomic) IBOutlet UITextField *message;

@property (weak, nonatomic) IBOutlet UITextField *password2;

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KviewColor;
}

//获取验证码
- (IBAction)sendMessage:(UIButton *)sender {
    _hudView = [Utils createHUD];
    _hudView.userInteractionEnabled = NO;
     _hudView.labelText = @"正在发送";
    _hudView.mode = MBProgressHUDModeCustomView;
    [_hudView hide:YES afterDelay:1];
    
    if ([Utils checkTelNumber:_phone.text]) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        NSMutableDictionary *paramter = [Utils createParamterAct:KgetCode Name:_phone.text Password:nil type:self.type_r Message:nil];
        [manager GET:KurlString parameters:paramter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            NSInteger isError = [responseObject[@"isError"] integerValue];
            if (!isError) {
                [Utils timeDecrease:sender];
                _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-done"]];
                _hudView.labelText = @"已发送";
                return ;
            }
            _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
            _hudView.labelText = @"号码已注册";
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
            _hudView.labelText = @"发送失败";
            
        }];
    }
    else{
        _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _hudView.labelText = @"输入的手机号码不合理";
    }
}

//提交账号信息
- (IBAction)sumbit:(UIButton *)sender {
    _hudView = [Utils createHUD];
    _hudView.userInteractionEnabled = NO;
    _hudView.labelText = @"正在提交";
    [_hudView hide:YES afterDelay:1];
    
    if (_phone.text.length == 0) {
        _hudView.labelText = @"请输入手机号码";
        return;
    }
    else if (![Utils checkTelNumber:_phone.text]){
        _hudView.labelText = @"输入的手机号码不合理";
        return;
    }
    else if (![_password1.text isEqualToString:_password2.text]||(_password1.text.length == 0)){
        _hudView.labelText = @"两次输入的密码有误";
        return;
    }
    else if (_message.text.length == 0){
        _hudView.labelText = @"请输入验证码";
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSMutableDictionary *paramter = [Utils  createParamterAct:_act Name:_phone.text Password:_password1.text type:self.type_r Message:_message.text];
    [manager POST:KurlString parameters:paramter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       NSInteger isError = [responseObject[@"isError"] integerValue];
        if (!isError) {
            _hudView.mode = MBProgressHUDModeCustomView;
            _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-done"]];
            _hudView.labelText = @"已完成";
            [self.navigationController popToRootViewControllerAnimated:NO];
            return ;
        }
          _hudView.mode = MBProgressHUDModeCustomView;
        _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _hudView.labelText = responseObject[@"errorMessage"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        _hudView.mode = MBProgressHUDModeCustomView;
        _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _hudView.labelText = @"网络异常，请检查网络";
    }];
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
