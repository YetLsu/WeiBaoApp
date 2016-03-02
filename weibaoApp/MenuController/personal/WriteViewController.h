//
//  WriteViewController.h
//  NewPower
//
//  Created by 刘毕涛 on 16/1/29.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ReturnTextBlock)(NSString *showText);

@interface WriteViewController : UIViewController

@property (nonatomic,copy) ReturnTextBlock returnTextBlock;

-(void)returnText:(ReturnTextBlock)block;

@end
