//
//  WBUser.h
//  NewPower
//
//  Created by 刘毕涛 on 16/1/30.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBUser : NSObject

@property (nonatomic,assign) NSInteger  userID;
@property (nonatomic,copy) NSString *phone;
@property (nonatomic,copy) NSString *userimg;
@property (nonatomic,copy) NSString *memo;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *usersex;
@property (nonatomic,copy) NSString *brithday;

-(instancetype)initWithDic:(NSDictionary *)dic;


@end
