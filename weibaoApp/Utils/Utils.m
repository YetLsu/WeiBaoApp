//
//  Utils.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/19.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "Utils.h"
#import <NSString+MD5.h>
#import <AFNetworking.h>

@interface Utils ()
@end

@implementation Utils

//创建一个等待框
+ (MBProgressHUD *)createHUD
{
    //取出最后的一个窗口
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:window];
    HUD.dimBackground = YES;
    HUD.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
    [window addSubview:HUD];
    [HUD show:YES];
    HUD.removeFromSuperViewOnHide = YES;
    return HUD;
}

//检测手机号码
+ (BOOL)checkTelNumber:(NSString *) telNumber
{
    NSString *pattern = @"^1+[3578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
    
}

+ (void)pollingNoticewithSupView:(UIView *)view{
    UIView *error_view = [[UIView alloc]initWithFrame:CGRectMake(0, 64, KscreenWidth, 30)];
    error_view.backgroundColor = KviewColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, KscreenWidth-30, 20)];
    UIImageView *error_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 14, 14)];
    error_imageView.image = [UIImage imageNamed:@"error"];
    label.text = @"   请检查网络";
    [error_view addSubview:error_imageView];
    [error_view addSubview:label];

    [view addSubview:error_view];
    [view bringSubviewToFront:error_view];
    
    
    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                error_view.hidden = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G|4G");
                error_view.hidden = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi");
                error_view.hidden = YES;
                break;
            default:
                break;
        }
    }];
    [manger startMonitoring];

}


+(void)timeDecrease:(UIButton *)button{
    __block int timeout=60; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [button setTitle:@"发送验证码" forState:UIControlStateNormal];
                button.userInteractionEnabled = YES;
            });
        }else{
            int seconds = timeout % 61;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [button setTitle:[NSString stringWithFormat:@"%@",strTime] forState:UIControlStateNormal];
                button .userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);

    
}


+(NSMutableDictionary *)createParamterAct:(NSString *)act Name:(NSString *)phone Password:(NSString *)password type:(NSString *)kind Message:(NSString *)message{
    NSMutableDictionary *paramter = [NSMutableDictionary dictionary];
    paramter[@"act"] = [[act dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    paramter[@"user_name"] = [[phone dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    paramter[@"user_pwd"] = [password MD5Digest];
    paramter[@"c_kind"] = [[kind dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    paramter[@"user_code"] = [[message dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    paramter[@"mKey"] = [[NSString stringWithFormat:@"%@%@",KsKey,[phone MD5Digest]] MD5Digest];
    
    return paramter;
}


+(NSMutableDictionary *)createParamterAct:(NSString *)act search:(NSString *)search left1:(CGFloat)left_1 left2:(CGFloat)left_2 right1:(CGFloat)right_1 right:(CGFloat)right_2{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"act"] = [[act dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    dic[@"search"] = [[search dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    dic[@"pos1_x"] = [[[NSString stringWithFormat:@"%f",left_1]dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    dic[@"pos1_y"] = [[[NSString stringWithFormat:@"%f",left_2]dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    dic[@"pos2_x"] = [[[NSString stringWithFormat:@"%f",right_1]dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    dic[@"pos2_y"] = [[[NSString stringWithFormat:@"%f",right_2]dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    NSString *str = [Utils getCondition];
    dic[@"cateid"] = [[str dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userDefaults objectForKey:Karray];
    
    dic[@"skind"] = [[arr[4] dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    dic[@"isnp"] = [[arr[5] dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    return dic;
}

+ (NSData *)compressImage:(UIImage *)image
{
    CGSize size = [self scaleSize:image.size];
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger maxFileSize = 500 * 1024;
    CGFloat compressionRatio = 0.7f;
    CGFloat maxCompressionRatio = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, compressionRatio);
    
    while (imageData.length > maxFileSize && compressionRatio > maxCompressionRatio) {
        compressionRatio -= 0.1f;
        imageData = UIImageJPEGRepresentation(image, compressionRatio);
    }
    
    return imageData;
}
+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    } else {
        return CGSizeMake(800 * width / height, 800);
    }
}

+(BOOL)isNull:(id)object{
    if ([object isEqual:[NSNull null]]) {
        return NO;
    }else if([object isKindOfClass:[NSNull class]]){
        return NO;
    }else if (object == nil){
        return NO;
    }else if ([object isKindOfClass:[NSString class]]){
        NSString *str = (NSString *)object;
        if (str.length == 0) {
            return NO;
        }
    }
    return YES;
}

+(NSString *)getCondition{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userDefaults objectForKey:Karray];
    if (![Utils isNull:arr]) {
        arr = @[@"1",@"1",@"1",@"1",@"1",@"1"];
    }
    NSString *str;
    for (int i = 0; i<(arr.count-2); i++) {
        if ([arr[i] isEqualToString:@"1"]) {
            if ([self isNull:str]) {
            str = [NSString stringWithFormat:@"%@,%d",str,i+1];
            }else{
            str = [NSString stringWithFormat:@"%d",i+1];
            }
        }
    }
    return str;
}


+(CLLocationCoordinate2D)baiduTomars:(CLLocationCoordinate2D)baiduCll{
    double longitudeBaidu = baiduCll.longitude;
    double latitudeBaidu = baiduCll.latitude;
    
    double x = longitudeBaidu - 0.0065;
    double y = latitudeBaidu - 0.006;
    
    double x_pi = x / 180.0;
    
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    
    double longitudeMars = z * cos(theta);
    double latitudeMars = z * sin(theta);
    return CLLocationCoordinate2DMake(latitudeMars, longitudeMars);
}
@end
