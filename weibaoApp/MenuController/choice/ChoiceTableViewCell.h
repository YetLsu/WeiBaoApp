//
//  ChoiceTableViewCell.h
//  NewPower
//
//  Created by 刘毕涛 on 16/1/29.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChoiceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageVIew;

@property (weak, nonatomic) IBOutlet UILabel *describe;

@property (weak, nonatomic) IBOutlet UISwitch *witch;



@end
