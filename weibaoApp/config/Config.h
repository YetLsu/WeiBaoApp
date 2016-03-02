//
//  Config.h
//  NewPower
//
//  Created by 刘毕涛 on 16/1/30.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBUser.h"
@interface Config : NSObject



+ (void)saveProfile:(WBUser *)user;

+(void)saveStr:(NSString *)str Kuser:(NSString *)key;

+ (WBUser *)myProfile;

+ (int64_t)getOwnID;

+ (void)clearProfile;

+(void)savememo:(NSString *)memo name:(NSString *)name sex:(NSString*)sex brithday:(NSString *)brithday;
@end
