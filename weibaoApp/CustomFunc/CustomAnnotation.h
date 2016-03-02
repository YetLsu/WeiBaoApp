//
//  CustomAnnotation.h
//  NewPower
//
//  Created by 刘毕涛 on 16/2/16.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import <AMapNaviKit/MAPointAnnotation.h>


@interface CustomAnnotation : MAPointAnnotation

@property (nonatomic,assign)  NSInteger  storeID;
@property (nonatomic,assign)  int mytype;
@property (nonatomic,copy)  NSString *rnum;
@property (nonatomic,assign)  BOOL isAppear;
@property (nonatomic,copy)    NSString  *pic1;
@property (nonatomic,copy)    NSString  *pic2;
@property (nonatomic,copy)    NSString  *pic3;
@property (nonatomic,copy)    NSString  *pic4;
@property (nonatomic,copy)    NSString  *pic5;
@property (nonatomic,copy)    NSString  *describe;
@property (nonatomic,copy)    NSString  *userName;
@property (nonatomic,copy)    NSString   *userPhone;
@property (nonatomic,copy)    NSString   *regtime;
@property (nonatomic,assign)    NSInteger  isdel;
@property (nonatomic,assign)    NSInteger  isnew;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end
