//
//  CustomCalloutView.h
//  weibaoApp
//
//  Created by 刘毕涛 on 16/2/29.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCalloutView : UIView

@property (nonatomic, strong) UIImage *image; //图片
@property (nonatomic, copy) NSString *number; //商户图
@property (nonatomic, copy) NSString *title; //商户名
@property (nonatomic, copy) NSString *subtitle; //地址
@end
