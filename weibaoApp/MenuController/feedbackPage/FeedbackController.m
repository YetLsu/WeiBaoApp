//
//  FeedbackController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/25.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "FeedbackController.h"
#import "PlaceholderTextView.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Utils.h"
#import <NSString+MD5.h>
@interface FeedbackController ()

@property (nonatomic,strong) PlaceholderTextView *feedbackTextView;
@property (nonatomic,strong) MBProgressHUD *HUD;


@end

@implementation FeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"意见反馈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(sendFeedback)];
    
    [self setLayout];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = KviewColor;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hide:YES];
    [super viewWillDisappear:animated];
}


- (void)setLayout
{
    _feedbackTextView = [PlaceholderTextView new];
    _feedbackTextView.placeholder = @"感谢您的反馈，请提出您的意见与建议";
    _feedbackTextView.layer.cornerRadius = 3.0;
    _feedbackTextView.layer.masksToBounds = YES;
    _feedbackTextView.font = [UIFont systemFontOfSize:15];
    _feedbackTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [_feedbackTextView becomeFirstResponder];
    [self.view addSubview:_feedbackTextView];
    _feedbackTextView.backgroundColor = [UIColor whiteColor];
    NSDictionary *views = NSDictionaryOfVariableBindings(_feedbackTextView);    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_feedbackTextView]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_feedbackTextView]-8-|"    options:0 metrics:nil views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view         attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:_feedbackTextView attribute:NSLayoutAttributeBottom  multiplier:1.0 constant:50.0]];

}

-(void)sendFeedback{
    _HUD = [Utils createHUD];
    _HUD.labelText = @"正在发送反馈";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"act"] = [[KsendMSg dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    NSString *phone = [userDefaults objectForKey:KuserPhone];
    parameter[@"user_name"] = [[phone dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    parameter[@"user_msg"] = [[_feedbackTextView.text dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    parameter[@"mKey"] = [[NSString stringWithFormat:@"%@%@",KsKey,[phone MD5Digest]] MD5Digest];
    
    [manager POST:KurlString parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [_HUD hide:YES];
        MBProgressHUD *HUD = [Utils createHUD];        
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
        HUD.labelText = @"发送成功，感谢您的反馈";
        [HUD hide:YES afterDelay:2];
        
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        _HUD.mode = MBProgressHUDModeCustomView;
        _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _HUD.labelText = @"网络异常，发送失败";
        [_HUD hide:YES afterDelay:1.0];
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
