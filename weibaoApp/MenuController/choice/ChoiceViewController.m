//
//  ChoiceViewController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/29.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "ChoiceViewController.h"
#import "ChoiceTableViewCell.h"
#import "Utils.h"
@interface ChoiceViewController ()
{
    NSArray *_dataArray;
}
@end


@implementation ChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KviewColor;
    self.title = @"站点类型";
    _dataArray = @[@[@"加油站",@"充电桩",@"普通4s店",@"新能源4s店"],@[@"公共设施"],@[@"支持新能源"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"ChoiceTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChoiceCell"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray[section] count];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChoiceCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.imageVIew.contentMode = UIViewContentModeScaleAspectFit;
    cell.describe.text = _dataArray[indexPath.section][indexPath.row];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefaults objectForKey:Karray];
    if ([Utils isNull:array]) {
        switch (indexPath.section) {
            case 0:
                if ([array[indexPath.row] isEqualToString:@"1"]) {
                    [cell.witch setOn:YES];
                }else{
                    [cell.witch setOn:NO];
                }
                break;
            case 1:{
                NSInteger i = indexPath.row +4;
                
                if ([array[i] isEqualToString:@"1"]) {
                   [cell.witch setOn:YES];
                }else{
                    [cell.witch setOn:NO];
                }
            }
                break;
            case 2:{
                NSInteger i = indexPath.row +5;
                
                if ([array[i] isEqualToString:@"1"]) {
                    [cell.witch setOn:YES];
                }else{
                    [cell.witch setOn:NO];
                }
            }
            default:
                break;
        }
        
    }else {
        [cell.witch setOn:YES];
        NSMutableArray *arr = [NSMutableArray arrayWithArray: @[@"1",@"1",@"1",@"1",@"1",@"1"
                                                            ]];
        [userDefaults setObject:arr forKey:Karray];
        [userDefaults synchronize];
    }
    switch (indexPath.section) {
        case 0:{
            NSInteger i = indexPath.row+1;
            cell.imageVIew.image = [UIImage imageNamed:[NSString stringWithFormat:@"gas%ld",(long)i]];
        }
            
            break;
            case 1:
            cell.imageVIew.image = [UIImage imageNamed:@"public1"];
            case 2:
            cell.imageVIew.image = [UIImage imageNamed:@"sustain"];
        default:
            break;
    }
    cell.witch.userInteractionEnabled = NO;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"能源性质";
        case 1:
            return @"网点性质";
        default:
            return @"";
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChoiceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone ];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *array = [[userDefaults objectForKey:Karray] mutableCopy];
    switch (indexPath.section) {
        case 0:
            if ([array[indexPath.row] isEqualToString:@"1"]) {
                [array replaceObjectAtIndex:indexPath.row withObject:@"0"];
            }else{
               [array replaceObjectAtIndex:indexPath.row withObject:@"1"];
            }
              break;
        case 1:{
             NSInteger i = indexPath.row +4;
            
            if ([array[i] isEqualToString:@"1"]) {
                [array replaceObjectAtIndex:i withObject:@"0"];
            }else{
               [array replaceObjectAtIndex:i withObject:@"1"];
            }
           
            break;
        }
        case 2:{
             NSInteger i = indexPath.row +5;
            if ([array[i] isEqualToString:@"1"]) {
               [array replaceObjectAtIndex:i withObject:@"0"];
            }else{
             [array replaceObjectAtIndex:i withObject:@"1"];
            }
        
             break;
        }
        default:
            break;
    }
    if (cell.witch.isOn) {
        [cell.witch setOn:NO];
    }else{
        [cell.witch setOn:YES];
    }
    [userDefaults setObject:array forKey:Karray];
    [userDefaults synchronize];
    
    if (self.refreshBlock != nil ) {
        self.refreshBlock();
    };
}

-(void)returnRefresh:(RefreshBlock )block{
    self.refreshBlock = block;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
