//
//  Config.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/30.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "Config.h"
#import "Utils.h"

@implementation Config

+ (void)saveProfile:(WBUser *)user{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:user.userID forKey:KuserID];
    [userDefaults setObject:user.phone forKey:KuserPhone];
    [userDefaults setObject:user.usersex forKey:KuserSex];
    [self saveStr:user.username Kuser:KuserName];
    [self saveStr:user.memo Kuser:KuserMemo];
    [self saveStr:user.userimg Kuser:Kuserimg];
    [self saveStr:user.brithday Kuser:KuserBrithday];
    
    [userDefaults synchronize];
}

+(void)saveStr:(NSString *)str Kuser:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([key isEqualToString:KuserBrithday]) {
        if (![str isEqualToString:@"0"]) {
            NSInteger i = [str integerValue];
            NSTimeInterval time=i+28800;
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            str = [dateFormatter stringFromDate:confromTimesp];
        }
    }
   else if ([Utils isNull:str]&&[key isEqualToString:Kuserimg] )
         {
            NSString *img = str;
            str = [NSString stringWithFormat:@"%@%@",KurlPhoto,img];
        }
    else{
        [userDefaults setObject:@"" forKey:key];
    }
    [userDefaults setObject:str forKey:key];
    [userDefaults synchronize];
}

+ (WBUser *)myProfile{
    WBUser *user = [[WBUser alloc]init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    user.userID = [userDefaults integerForKey:KuserID];
    user.phone = [userDefaults objectForKey:KuserPhone];
    user.userimg = [userDefaults objectForKey:Kuserimg];
    user.memo = [userDefaults objectForKey:KuserMemo];
    user.username = [userDefaults objectForKey:KuserName];
    user.usersex = [userDefaults objectForKey:KuserSex];
    user.brithday = [userDefaults objectForKey:KuserBrithday];
    if (user.userID) {
        if (![Utils isNull:user.username]) {
            user.username = user.phone;
        }
        
    }else{
        user.username = @"登录/注册";
    }
    if (![Utils isNull:user.memo]) {
       user.memo = @"请输入";
    }
    if (![Utils isNull:user.brithday]) {
        user.brithday = @"请输入您的生日";
    }
    return user;
}

+ (int64_t)getOwnID{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:KuserID];
}

+ (void)clearProfile{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:0 forKey:KuserID];
    [userDefaults setObject:@"" forKey:KuserName];
    [userDefaults setObject:@"" forKey:KuserPhone];
    [userDefaults setObject:@"" forKey:KuserMemo];
    [userDefaults setObject:@"" forKey:Kuserimg];
    [userDefaults setObject:@"" forKey:KuserBrithday];
    [userDefaults setObject:@"" forKey:KuserSex];
    
    [userDefaults synchronize];
}
+(void)savememo:(NSString *)memo name:(NSString *)name sex:(NSString*)sex brithday:(NSString *)brithday{
    [self saveStr:memo Kuser:KuserMemo];
    [self saveStr:name Kuser:KuserName];
    if ([sex isEqualToString:@"1"]) {
        [self saveStr:@"男" Kuser:KuserSex];
    }else{
        [self saveStr:@"女" Kuser:KuserSex];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:brithday forKey:KuserBrithday];
    [userDefaults synchronize];
}

@end
