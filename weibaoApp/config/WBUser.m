//
//  WBUser.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/30.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "WBUser.h"

@implementation WBUser


-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _userID = [dic[@"id"] integerValue];
        _phone = dic[@"phone"];
        _userimg =  dic[@"userimg"];
        _memo = dic[@"memo"];
        _username = dic[@"username"];
        _usersex = [dic[@"usersex"] isEqualToString:@"1"]? @"男": @"女";
        _brithday = dic[@"birthday"];
    }
    return self;
}

-(NSString *)description{
    return  [NSString stringWithFormat:@"id是%ld,手机是%@,头像是%@,签名是%@,用户名是%@,性别是%@,生日是%@",(long)_userID,_phone,_userimg,_memo,_username,_usersex,_brithday];
}

@end
