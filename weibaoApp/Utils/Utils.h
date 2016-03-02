//
//  Utils.h
//  NewPower
//
//  Created by 刘毕涛 on 16/1/19.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>
#import <AFNetworkReachabilityManager.h>
#import <AMapNaviKit/MAMapKit.h>

@interface Utils : NSObject


+ (MBProgressHUD *)createHUD;

//检查手机号
+ (BOOL)checkTelNumber:(NSString *) telNumber;

//检查网络
+ (void)pollingNoticewithSupView:(UIView *)view;

//按钮标题跳动
+(void)timeDecrease:(UIButton *)button;


+(NSMutableDictionary *)createParamterAct:(NSString *)act Name:(NSString *)name Password:(NSString *)password type:(NSString *)kind Message:(NSString *)message;


+(NSMutableDictionary *)createParamterAct:(NSString *)act search:(NSString *)search left1:(CGFloat)left_1 left2:(CGFloat)left_2 right1:(CGFloat)right_1 right:(CGFloat)right_2;

+ (NSData *)compressImage:(UIImage *)image;


+(BOOL)isNull:(id)object;

+(NSString *)getCondition;

+(CLLocationCoordinate2D)baiduTomars:(CLLocationCoordinate2D)baiduCll;

@end
