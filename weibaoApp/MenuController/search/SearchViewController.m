//
//  SearchViewController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/2/16.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "SearchViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Utils.h"
#import <AMapNaviKit/MAMapKit.h>

@interface SearchViewController ()<UIGestureRecognizerDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    UISearchBar *_searchView;
    NSMutableArray *_dataArray;
}

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KscreenWidth, KscreenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.alpha = 0.8;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
 
    _searchView = [[UISearchBar alloc]init];
    _searchView.barStyle = UIBarStyleDefault;
    _searchView.backgroundColor = [UIColor clearColor];
    _searchView.placeholder = @"请输入地点";
    for (UIView *view in _searchView.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    _searchView.tintColor=[UIColor blueColor];
    _searchView.delegate = self;
    self.navigationItem.titleView = _searchView;
    [_searchView becomeFirstResponder];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
    
}
//隐藏键盘栏
- (void)hidenKeyboard
{
    [_searchView resignFirstResponder];
}

//确定这个手势是否可以实现
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //判断这个账号和密码控件中是否都是第一响应者
    if (![_searchView isFirstResponder]) {
        
        //都不是第一响应者的时候
        return NO;
    }
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self requestWith:_searchView.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
     [self requestWith:searchBar.text];
    
}

-(void)requestWith:(NSString *)poi{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];    
    NSMutableDictionary *pareter = [NSMutableDictionary dictionary];
    pareter[@"act"] = [[Kget_mapPos dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    pareter[@"search"] = [[poi dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    NSString *str = [Utils getCondition];
    pareter[@"cateid"] = [[str dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userDefaults objectForKey:Karray];    
    pareter[@"skind"] = [[arr[4] dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    pareter[@"isnp"] = [[arr[5] dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
    
    [manager GET:Kmap_url parameters:pareter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger isError = [responseObject[@"isError"] integerValue];
        if (!isError) {
            [_dataArray removeAllObjects];
            NSArray *array = responseObject[@"result"];
            for (NSDictionary *dic in array) {
                 CustomAnnotation *point = [[CustomAnnotation alloc]initWithDic:dic];
                point.isAppear = YES;
                [_dataArray addObject:point];
            }
              [_tableView reloadData];
       
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
 
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    CustomAnnotation *annotation = _dataArray[indexPath.row];

    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gas%d",annotation.mytype]];
    CGSize itemSize = CGSizeMake(23,30);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.text = annotation.title;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.text = annotation.subtitle;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //相当于是给returnTextBlock的参数赋值
    if (self.returnAnnBlock!=nil) {
        CustomAnnotation *ann = _dataArray[indexPath.row];
        //调用了这个block
        self.returnAnnBlock(ann);
    }
    [self.navigationController popViewControllerAnimated:NO];
   
}

-(void)returnText:(ReturnAnnBlock)block{
    self.returnAnnBlock=block;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
