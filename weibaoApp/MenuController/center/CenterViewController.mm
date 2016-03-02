//
//  CenterViewController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/18.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "CenterViewController.h"
#import <UIViewController+MMDrawerController.h>
#import <AMapNaviKit/MAMapKit.h>
#import <MBProgressHUD.h>
#import "Utils.h"
#import "GuidaceViewController.h"
#import "LoginViewController.h"
#import "ChoiceViewController.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "SearchViewController.h"
#import "CustomAnnotation.h"
#import "DetailedViewController.h"


@interface CenterViewController ()<MAMapViewDelegate,UISearchBarDelegate>
{
    UISearchBar *_searchView;
    MAMapView *_mapView;
    MBProgressHUD *_hudView;
    CLLocationCoordinate2D  _left_p1;
    CLLocationCoordinate2D  _right_p2;
    NSMutableArray *_dataArray;
    
    BOOL _isOn;
}

@end

@implementation CenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.title = @"返回";
    self.view.backgroundColor = [UIColor whiteColor];
    _hudView = [Utils createHUD];
    _hudView.labelText = @"正在定位";
    [_hudView hide:YES afterDelay:1];
    _hudView.userInteractionEnabled = NO;
    
    //创建导航栏上的界面
    [self creatSideButton];
    
    //设置地图的样式
    [self create_mapView];
}

-(void)create_mapView{

    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    //实现定位功能
    _mapView.showsUserLocation = YES;
    _mapView.userLocation.title = nil;
    
    //变化比例尺的位置
    _mapView.scaleOrigin = CGPointMake(20, KscreenHeight-40);
    //指南针
    _mapView.compassOrigin = CGPointMake(KscreenWidth-60, 70);
    
    _mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    [_mapView setZoomLevel:15 animated:YES];
    
    //后台定位
    _mapView.pausesLocationUpdatesAutomatically = NO;
    _mapView.allowsBackgroundLocationUpdates = YES;
    [self.view addSubview:_mapView];
    

    //检测网络
    [Utils pollingNoticewithSupView:_mapView];
    
    //创建回到定位的按钮
    UIButton *location_btn = [UIButton buttonWithType:UIButtonTypeSystem];
    location_btn.tag = 1;
    location_btn.frame = CGRectMake(KscreenWidth-60, KscreenHeight-60,40,40);
    [location_btn setBackgroundImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
    [location_btn setBackgroundImage:[UIImage imageNamed:@"10"] forState:UIControlStateHighlighted];
    [location_btn addTarget:self action:@selector(location_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:location_btn];
    //创建导航按钮
    UIButton *navi_btn = [UIButton buttonWithType:UIButtonTypeSystem];
    navi_btn.tag = 2;
    navi_btn.frame = CGRectMake(KscreenWidth-60, KscreenHeight-120,40,40);
    [navi_btn setBackgroundImage:[UIImage imageNamed:@"2"] forState:UIControlStateNormal];
    [navi_btn setBackgroundImage:[UIImage imageNamed:@"20"] forState:UIControlStateHighlighted];
    [navi_btn addTarget:self action:@selector(location_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navi_btn];
    //创建选项
    UIButton *option_btn = [UIButton buttonWithType:UIButtonTypeSystem];
    option_btn.tag = 3;
    option_btn.frame = CGRectMake(KscreenWidth-60, KscreenHeight-180,40,40);
    [option_btn setBackgroundImage:[UIImage imageNamed:@"3"] forState:UIControlStateNormal];
    [option_btn setBackgroundImage:[UIImage imageNamed:@"30"] forState:UIControlStateHighlighted];
    [option_btn addTarget:self action:@selector(location_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:option_btn];
}
                  
-(void)location_action:(UIButton *)button{
    CGFloat latitude = _mapView.userLocation.location.coordinate.latitude;
    CGFloat longitude = _mapView.userLocation.location.coordinate.longitude;
    if (!_hudView.hidden) {
        _hudView.hidden = YES;
    }
    switch (button.tag) {
        case 1:{
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(latitude,longitude) animated:YES];
            break;}
        case 2:{
            ChoiceViewController *choiceVC = [[ChoiceViewController alloc]init];
            __weak CenterViewController *_weakself = self;
            [choiceVC returnRefresh:^{
                [_weakself request];
            }];
            [self.navigationController pushViewController:choiceVC animated:YES];
            break;}
        case 3:{
            GuidaceViewController *guidaceVC = [[GuidaceViewController alloc]init];
            [self.navigationController pushViewController:guidaceVC animated:YES];
            break;
        }
    }
}

#pragma mark－ 地图定位

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    _hudView.mode = MBProgressHUDModeCustomView;
    _hudView.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HUD-error"]];
    _hudView.labelText = @"定位失败";
    [_hudView hide:YES afterDelay:2];
}

#pragma mark ----创建导航栏上的按钮
-(void)creatSideButton{
    //左边的
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigationbar-sidebar"] style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick:)];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    _searchView = [[UISearchBar alloc]init];
    _searchView.barStyle = UIBarStyleDefault;
    _searchView.backgroundColor = [UIColor clearColor];
    _searchView.placeholder = @"请输入地点";
    _searchView.delegate = self;
    for (UIView *view in _searchView.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    _searchView.tintColor=[UIColor blueColor];
    self.navigationItem.titleView = _searchView;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;{
    if (!self.mm_drawerController.visibleLeftDrawerWidth) {
        SearchViewController *searchVC = [[SearchViewController alloc]init];
        __weak MAMapView *weakMap = _mapView;
        
        [searchVC returnText:^(CustomAnnotation *ann) {
            _isOn = YES;
            [weakMap setCenterCoordinate:CLLocationCoordinate2DMake(ann.coordinate.latitude,ann.coordinate.longitude) animated:YES];
            [weakMap removeAnnotation:ann];
            [weakMap addAnnotation:ann];
            [_mapView selectAnnotation:ann animated:YES];
        }];
        [self.navigationController pushViewController:searchVC animated:YES];
        return YES;
    }
    return NO;
}

-(void)request{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSDictionary *pareter = [Utils createParamterAct:Kget_mapPos search:nil left1:_left_p1.longitude left2:_left_p1.latitude right1:_right_p2.longitude right:_right_p2.latitude];
    [manager GET:Kmap_url parameters:pareter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger isError = [responseObject[@"isError"] integerValue];
        if (!isError) {
            [_dataArray removeAllObjects];
            NSArray *array = responseObject[@"result"];
            for (NSDictionary *dic in array) {
                CustomAnnotation *point = [[CustomAnnotation alloc]initWithDic:dic];
                [_dataArray addObject:point];
            }
            if (![Utils isNull:_dataArray]) {
                return ;
            }
            NSArray *array1 = [NSArray arrayWithArray:_mapView.annotations];
            NSPredicate *thePredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", _dataArray];
             NSPredicate *thePredicate2 = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", array1];
            [array1 filteredArrayUsingPredicate:thePredicate1];
            [_dataArray filteredArrayUsingPredicate:thePredicate2];
            [_mapView removeAnnotations:array1];
            [_mapView addAnnotations:_dataArray];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
}

//跳出左边框
-(void)leftButtonClick:(UIBarButtonItem *)sender{
    if (!_hudView.hidden) {
        _hudView.hidden = YES;
    }
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)getregion{
    CGFloat centerLongitude = _mapView.region.center.longitude;
    CGFloat centerLatitude = _mapView.region.center.latitude;
    CLLocationDegrees pointssLongitudeDelta = _mapView.region.span.longitudeDelta;
    CLLocationDegrees pointssLatitudeDelta = _mapView.region.span.latitudeDelta;
    CGFloat leftDownLong = centerLongitude - pointssLongitudeDelta/2.0;
    CGFloat leftDownlati = centerLatitude - pointssLatitudeDelta/2.0;
    _left_p1 = CLLocationCoordinate2DMake(leftDownlati, leftDownLong);
    CGFloat rightUpLong = centerLongitude + pointssLongitudeDelta/2.0;
    CGFloat rightUpLati = centerLatitude + pointssLatitudeDelta/2.0;
    _right_p2 = CLLocationCoordinate2DMake(rightUpLati, rightUpLong);
}

#pragma mark----地图的代理方法

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    if (_isOn) {
    return;
  }
    [self getregion];
    [self request];
   
    
}
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (_isOn) {
        _isOn = NO;
    }
    
}

- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[CustomAnnotation class]]){
    CustomAnnotation   *ann = (CustomAnnotation *)annotation;
    MAPinAnnotationView  *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"myAnnotation"];
    if (annotationView == nil) {
        annotationView = [[MAPinAnnotationView alloc]initWithAnnotation:ann reuseIdentifier:@"myAnnotation"];
        annotationView.animatesDrop = NO;
    }
        
    annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gas%d",ann.mytype]];
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -18);
    annotationView.annotation = ann;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 27)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"11"];
    annotationView.rightCalloutAccessoryView = imageView;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    

    
    return annotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        view.canShowCallout = NO;
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}
//点击气泡
- (void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view;{
    CustomAnnotation *ann = (CustomAnnotation *)view.annotation;
    DetailedViewController *detailedVC = [[DetailedViewController alloc]initWithStore:ann];
    [self.navigationController pushViewController:detailedVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
