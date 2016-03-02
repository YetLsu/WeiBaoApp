//
//  LeftViewController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/18.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "LeftViewController.h"
#import <UIViewController+MMDrawerController.h>
#import "LoginViewController.h"
#import "CenterViewController.h"
#import "WBUser.h"
#import "Config.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AboutViewController.h"
#import "PersonalViewController.h"
#import "FeedbackController.h"
#import "ChoiceViewController.h"
#import "Utils.h"
#import <MBProgressHUD.h>

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate>
{
 
    
    NSArray *_dataArray;
    NSArray *_imageArray;
    
    MBProgressHUD *_hudView;
    
}

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = KthemeColor;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KscreenWidth*0.7, KscreenHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    [self.view addSubview:_tableView];
    [self refresh];
    
    //接受消息，，，当变换用户的时候
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"userRefresh" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refresh{
    if ([Config getOwnID]) {
        _dataArray = @[@"地图",@"个人资料",@"意见反馈",@"设置",@"清除缓存",@"注销",@"关于我们"];
        _imageArray = @[@"ic_map_48pt",@"ic_account_box_48pt",@"ic_feedback_48pt",@"ic_settings_48pt",@"ic_delete_forever_48pt",@"ic_close_48pt",@"ic_info_48pt"];
    }else{
         _dataArray = @[@"地图",@"设置",@"清除缓存",@"关于我们"];
        _imageArray = @[@"ic_map_48pt",@"ic_settings_48pt",@"ic_delete_forever_48pt",@"ic_info_48pt"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"leftcellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor =[UIColor clearColor];
    }
    
    NSString *str = _imageArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:str];
    CGSize itemSize = CGSizeMake(25,26);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.text = _dataArray[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 160;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    WBUser *user = [Config myProfile];
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor clearColor];
    UIImageView *avatar = [[UIImageView alloc]init];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    avatar.layer.cornerRadius = 30;
    avatar.layer.masksToBounds = YES;
    if ( user.userID ) {
       NSString *str = [NSString stringWithFormat:@"%@",user.userimg];
       NSURL *url_image = [NSURL URLWithString:str];
       [avatar sd_setImageWithURL:url_image placeholderImage:[UIImage imageNamed:@"default－portrait"] options:0];
    }else{
    avatar.image = [UIImage imageNamed:@"default－portrait"];
    }
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:avatar];
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.text = user.username;
    nameLabel.font = [UIFont boldSystemFontOfSize:18];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:nameLabel];

    NSDictionary *views = NSDictionaryOfVariableBindings(avatar, nameLabel);
    NSDictionary *metrics = @{@"x": @((KscreenWidth*0.6 - 60)/2)};
    //屏幕适配头像
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[avatar(60)]-10-[nameLabel]-15-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-x-[avatar(60)]" options:0 metrics:metrics views:views]];
    //给头像和用户名加点击事件
    avatar.userInteractionEnabled = YES;
    nameLabel.userInteractionEnabled = YES;
    [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginPage)]];
    [nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginPage)]];
    return headerView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //左侧的界面消失
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    
    UINavigationController *nav = (UINavigationController *)self.mm_drawerController.centerViewController;
    __weak CenterViewController *centerVC = (CenterViewController *)nav.childViewControllers[0];
    
   
    
    if ([Config getOwnID]) {
        switch (indexPath.row) {
            case 1:{
                PersonalViewController *personalVC = [[PersonalViewController alloc]init];
                [nav pushViewController:personalVC animated:YES];
            }
                break;
            case 2:{
                FeedbackController *feedbackVC = [[FeedbackController alloc]init];
                [nav pushViewController:feedbackVC animated:YES];
            }
                break;
            case 3:{
                ChoiceViewController *choiceVC = [[ChoiceViewController alloc]init];
                [choiceVC returnRefresh:^{
                    [centerVC request];
                }];
                [nav pushViewController:choiceVC animated:YES];
            }
                break;
            case 4:{
                [[SDImageCache sharedImageCache] clearDisk];
                _hudView = [Utils createHUD];
                _hudView.userInteractionEnabled = NO;
                [_hudView hide:YES afterDelay:1];
                _hudView.labelText = @"正在清除";
            }
                break;
            case 5:{
                [Config clearProfile];
                _hudView = [Utils createHUD];
                _hudView.userInteractionEnabled = NO;
                [_hudView hide:YES afterDelay:1];
                _hudView.labelText = @"注销成功";
                [self refresh];
            }
                break;
            case 6:{
                AboutViewController *aboutVC = [[AboutViewController alloc]init];
                [nav pushViewController:aboutVC animated:YES];
            }
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 1:
            {
                ChoiceViewController *choiceVC = [[ChoiceViewController alloc]init];
                [nav pushViewController:choiceVC animated:YES];
            }
                break;
            case 2:{
                [[SDImageCache sharedImageCache] clearDisk];
                _hudView = [Utils createHUD];
                _hudView.userInteractionEnabled = NO;
                [_hudView hide:YES afterDelay:1];
                _hudView.labelText = @"正在清除";
            }
                break;
            case 3:{
                AboutViewController *aboutVC = [[AboutViewController alloc]init];
                [nav pushViewController:aboutVC animated:YES];
            }
            default:
                break;
        }
    }

    
}

//登录及注册
-(void)pushLoginPage{
    if ([Config getOwnID]) {
        return;
    }else{
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *nav = (UINavigationController*) self.mm_drawerController.centerViewController;
        [nav pushViewController:login animated:YES];
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
