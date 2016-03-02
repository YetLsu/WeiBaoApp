//
//  SearchViewController.h
//  NewPower
//
//  Created by 刘毕涛 on 16/2/16.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAnnotation.h"

typedef void(^ReturnAnnBlock)(CustomAnnotation *ann);

@interface SearchViewController : UIViewController

@property (nonatomic,copy) ReturnAnnBlock returnAnnBlock;

-(void)returnText:(ReturnAnnBlock)block;
@end
