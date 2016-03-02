//
//  PersonalViewController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/29.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "PersonalViewController.h"
#import "Utils.h"
#import <MBProgressHUD.h>
#import "WriteViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"
#import "WBUser.h"
#import "Config.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking.h>
#import <NSString+MD5.h>
#import <UIViewController+MMDrawerController.h>
#import "LeftViewController.h"

@interface PersonalViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_dataArray;
    NSArray *_detailedArray;
    MBProgressHUD *_hudView;
    UIImage *_image;
    UIImageView *_imageView;
    UIView *view1;
    NSString *_birthday;
    
    NSMutableArray *yearArray;
    NSArray *monthArray;
    NSMutableArray *monthMutableArray;
    NSMutableArray *DaysMutableArray;
    NSMutableArray *DaysArray;
    NSString *currentMonthString;
    
    NSInteger selectedYearRow;
    NSInteger selectedMonthRow;
    NSInteger selectedDayRow;
    
    BOOL firstTimeLoad;
    
    NSInteger m ;
    int year;
    int month;
    int day;
}
@property (nonatomic,strong) UIPickerView *customPicker;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    [self.view addSubview:_tableView];
    self.title = @"个人资料";
    view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KscreenWidth, KscreenHeight)];
    view1.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(10, KscreenHeight-240, KscreenWidth-20, 40)];
    view2.backgroundColor = [UIColor whiteColor];
    [view1 addSubview:view2];
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel.frame = CGRectMake(20, KscreenHeight-240, 40, 40);
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    cancel.backgroundColor = [UIColor whiteColor];
    [cancel setTitleColor:[UIColor colorWithRed:23/255.0 green:122/255.0 blue:33/255.0 alpha:1] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:cancel];
    UIButton *determine = [UIButton buttonWithType:UIButtonTypeSystem];
    [determine setTitle:@"确定" forState:UIControlStateNormal];
    determine.backgroundColor = [UIColor whiteColor];
    [determine setTitleColor:[UIColor colorWithRed:23/255.0 green:122/255.0 blue:33/255.0 alpha:1] forState:UIControlStateNormal];
    determine.frame = CGRectMake( KscreenWidth-60,KscreenHeight-240, 40, 40);
    [determine addTarget:self action:@selector(certain:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:determine];
    _customPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(10, KscreenHeight-200, KscreenWidth-20, 170)];
    _customPicker.backgroundColor = [UIColor whiteColor];
    _customPicker.delegate = self;
    _customPicker.dataSource = self;
    [view1 addSubview:_customPicker];
    [_tableView addSubview:view1];
    
    m=0;
    firstTimeLoad = YES;
    view1.hidden = YES;
    NSDate *date = [NSDate date];
    
    // Get Current Year
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSString *currentyearString = [NSString stringWithFormat:@"%@",
                                   [formatter stringFromDate:date]];
    year =[currentyearString intValue];

    // Get Current  Month
    [formatter setDateFormat:@"MM"];
    currentMonthString = [NSString stringWithFormat:@"%ld",(long)[[formatter stringFromDate:date]integerValue]];
    month=[currentMonthString intValue];
    
    // Get Current  Date
    [formatter setDateFormat:@"dd"];
    NSString *currentDateString = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    day =[currentDateString intValue];
    
    yearArray = [[NSMutableArray alloc]init];
    monthMutableArray = [[NSMutableArray alloc]init];
    DaysMutableArray= [[NSMutableArray alloc]init];
    for (int i = 1970; i <= year ; i++)
    {
        [yearArray addObject:[NSString stringWithFormat:@"%d",i]];
        
    }
    // PickerView -  Months data
    
    monthArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    for (int i=1; i<month+1; i++) {
        [monthMutableArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    DaysArray = [[NSMutableArray alloc]init];
    
    for (int i = 1; i <= 31; i++)
    {
        [DaysArray addObject:[NSString stringWithFormat:@"%d",i]];
        
    }
    for (int i = 1; i <day+1; i++)
    {
        [DaysMutableArray addObject:[NSString stringWithFormat:@"%d",i]];
        
    }
    // PickerView - Default Selection as per current Date
    // 设置初始默认值
    [self.customPicker selectRow:20 inComponent:0 animated:YES];
    [self.customPicker selectRow:[monthArray indexOfObject:currentMonthString] inComponent:1 animated:YES];
    [self.customPicker selectRow:0 inComponent:2 animated:YES];
    
    [self.view addSubview:view1];
    
    _dataArray = @[@[@"头像"],@[@"签名"],@[@"昵称",@"性别",@"生日"]];
    WBUser *user = [Config myProfile];
    _detailedArray = @[@[user.userimg],@[user.memo],@[user.username,user.usersex,user.brithday]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = KviewColor;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    m=row;
    if (component == 0)
    {
        selectedYearRow = row;
        [self.customPicker reloadAllComponents];
    }
    else if (component == 1)
    {
        selectedMonthRow = row;
        [self.customPicker reloadAllComponents];
    }
    else if (component == 2)
    {
        selectedDayRow = row;
        
        [self.customPicker reloadAllComponents];
        
    }
    
}

#pragma mark - UIPickerViewDatasource

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    // Custom View created for each component
    
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, 50, 60);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:15.0f]];
    }
    if (component == 0)
    {
        pickerLabel.text =  [yearArray objectAtIndex:row]; // Year
    }
    else if (component == 1)
    {
        pickerLabel.text =  [monthArray objectAtIndex:row];  // Month
    }
    else if (component == 2)
    {
        pickerLabel.text =  [DaysArray objectAtIndex:row]; // Date
        
    }
    return pickerLabel;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 3;
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [yearArray count];
        
    }
    else if (component == 1)
    {
        NSInteger selectRow =  [pickerView selectedRowInComponent:0];
        int n;
        n= year-1970;
        if (selectRow==n) {
            return [monthMutableArray count];
        }else
        {
            return [monthArray count];
        }
    }
    else
    {
        NSInteger selectRow1 =  [pickerView selectedRowInComponent:0];
        int n;
        n= year-1970;
        NSInteger selectRow =  [pickerView selectedRowInComponent:1];
        if (selectRow==month-1 &selectRow1==n) {
            return day;
        }else{
            if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 || selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11)
            {
                return 31;
            }
            else if (selectedMonthRow == 1)
            {
                int yearint = [[yearArray objectAtIndex:selectedYearRow]intValue ];
                if(((yearint %4==0)&&(yearint %100!=0))||(yearint %400==0)){
                    return 29;
                }
                else
                {
                    return 28; // or return 29
                }
            }
            else
            {
                return 30;
            }
        }
    }
    
}

-(void)cancel:(UIButton *)sender{
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view1.hidden = YES;
                     }
                     completion:^(BOOL finished){
                     }];
}

-(void)certain:(UIButton *)sender{
      _birthday = [NSString stringWithFormat:@"%@-%@-%@ ",[yearArray objectAtIndex:[self.customPicker selectedRowInComponent:0]],[monthArray objectAtIndex:[self.customPicker selectedRowInComponent:1]],[DaysArray objectAtIndex:[self.customPicker selectedRowInComponent:2]]];
     NSString *str = [_detailedArray[2][1] isEqualToString:@"男"] ? @"1":@"0";
    [self updatePersonal:_detailedArray[2][0] brithday:_birthday sex:str memo:_detailedArray[1][0]];
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view1.hidden = YES;
                     }
                     completion:^(BOOL finished){
                     }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LeftViewController *leftVC = (LeftViewController *)self.navigationController.mm_drawerController.leftDrawerViewController;
        [leftVC.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setting" ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"setting"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _dataArray[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (indexPath.section == 0) {
        NSURL *url_image = [NSURL URLWithString:_detailedArray[indexPath.section][indexPath.row]];
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(KscreenWidth-80, 7, 30, 30)];
        [_imageView sd_setImageWithURL:url_image placeholderImage:[UIImage imageNamed:@"default－portrait"] options:0];
        [cell.contentView addSubview:_imageView];
    }
    else{
        cell.detailTextLabel.text = _detailedArray[indexPath.section][indexPath.row];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 44;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KscreenWidth, 1)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.7;
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *bri = [userDefaults objectForKey:KuserBrithday];
    if (indexPath.section == 1 || indexPath.section == 2) {
        if (indexPath.section ==2 &&indexPath.row == 1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择性别" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([_detailedArray[2][1]isEqualToString:@"男"]) {
                    return ;
                }
                [self updatePersonal:_detailedArray[2][0] brithday:bri sex:@"1" memo:_detailedArray[1][0]];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([_detailedArray[2][1]isEqualToString:@"女"]) {
                    return ;
                }
                [self updatePersonal:_detailedArray[2][0] brithday:bri sex:@"0" memo:_detailedArray[1][0]];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
            [alertController addAction:action1];
            [alertController addAction:action2];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:NO completion:nil];
        }else if (indexPath.section == 2&& indexPath.row == 2){
            view1.hidden = NO;
        }else{
        WriteViewController *writeVC = [[WriteViewController alloc]init];
            __weak PersonalViewController *_weakself = self;
        [writeVC returnText:^(NSString *showText) {
            NSString *str = [_detailedArray[2][1] isEqualToString:@"男"] ? @"1":@"0";
            if (indexPath.section ==1 && indexPath.row ==0) {
            [_weakself updatePersonal:_detailedArray[2][0] brithday:bri sex:str memo:showText];
            }else if (indexPath.section == 2 &&indexPath.row == 0){
            [_weakself updatePersonal:showText brithday:bri  sex:str memo:_detailedArray[1][0]];
            }
               [_weakself.navigationController popViewControllerAnimated:YES];
        }];
        [self.navigationController pushViewController:writeVC animated:YES];
        }
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action_photo = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *pickVC = [[UIImagePickerController alloc]init];
            pickVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickVC.delegate = self;
            pickVC.allowsEditing = YES;
            [self presentViewController:pickVC animated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
        [alertController addAction:action_photo];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)updatePersonal:(NSString *)name brithday:(NSString *)brithday sex:(NSString *)sex memo:(NSString *)memo{
    _hudView = [Utils createHUD];
    _hudView.userInteractionEnabled = NO;
    _hudView.labelText = @"正在修改";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSUserDefaults *userDefaluts =[NSUserDefaults standardUserDefaults];
    NSString *phone = [userDefaluts objectForKey:KuserPhone];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"act"] = [[KeditMem dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    parameter[@"user_name"] = [[phone dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    parameter[@"mKey"] = [[NSString stringWithFormat:@"%@%@",KsKey,[phone MD5Digest]] MD5Digest];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"username"] = name;
    dic[@"birthday"] = brithday;
    dic[@"usersex"] = sex;
    dic[@"memo"] = memo;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
   NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    parameter[@"user_info"] = str;
    [manager POST:KurlString parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger isError = [responseObject[@"isError"] integerValue];
        if (!isError) {
            [_hudView hide:YES];
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
            HUD.labelText = @"修改成功";
            [HUD hide:YES afterDelay:2];
            [Config savememo:memo name:name sex:sex brithday:brithday];
            WBUser *user = [Config myProfile];
            _detailedArray = @[@[user.userimg],@[user.memo],@[user.username,user.usersex,user.brithday]];
            LeftViewController *leftVC = (LeftViewController *)self.navigationController.mm_drawerController.leftDrawerViewController;
            [leftVC.tableView reloadData];
            [_tableView reloadData];
        }
        else{
            _hudView.mode = MBProgressHUDModeCustomView;
            _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
            _hudView.labelText = responseObject[@"errorMessage"];
            [_hudView hide:YES afterDelay:1];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        _hudView.mode = MBProgressHUDModeCustomView;
        _hudView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _hudView.labelText = @"网络异常，修改失败";
         [_hudView hide:YES afterDelay:1];
    }];
}

-(void)updatePotrait{
    _hudView = [Utils createHUD];
    _hudView.labelText = @"正在上传头像";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSUserDefaults *userDefaluts =[NSUserDefaults standardUserDefaults];
    NSString *phone = [userDefaluts objectForKey:KuserPhone];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"act"] =[[KsaveFile dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    NSData *data =  UIImageJPEGRepresentation(_image, 0.7);
    NSString *str1 =  [data base64EncodedStringWithOptions:0];
    parameter[@"user_file"] = str1;
    parameter[@"file_kind"] = [[@"1" dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    parameter[@"user_name"] = [[phone dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    parameter[@"mKey"] = [[NSString stringWithFormat:@"%@%@",KsKey,[phone MD5Digest]] MD5Digest];
    [manager POST:KurlString parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传图像：%@",responseObject);
        _hudView.mode = MBProgressHUDModeCustomView;
        NSInteger isError = [responseObject[@"isError"] integerValue];
        if (!isError) {
            _hudView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
            _hudView.labelText = @"头像更新成功";
            NSString *str = [NSString stringWithFormat:@"%@%@",KurlPhoto,responseObject[@"result"]];
           [userDefaluts setObject:str forKey:Kuserimg];
            [userDefaluts synchronize];
            LeftViewController *leftVC = (LeftViewController *)self.navigationController.mm_drawerController.leftDrawerViewController;
                [leftVC.tableView reloadData];
                _imageView.image = _image;
        }
        else{
            _hudView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
            _hudView.labelText = @"上传失败";
        }
        [_hudView hide:YES afterDelay:1];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        _hudView.mode = MBProgressHUDModeCustomView;
        _hudView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        _hudView.labelText = @"网络异常，头像更换失败";
        [_hudView hide:YES afterDelay:1];
    }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    _image = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self updatePotrait];
    }];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
