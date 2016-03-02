//
//  DetailedViewController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/30.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "DetailedViewController.h"
#import "Utils.h"
#import "LoopPageView.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapNaviKit/MAMapKit.h>

#import "iflyMSC/IFlySpeechError.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"

@interface DetailedViewController ()<UITableViewDataSource,UITableViewDelegate,MAMapViewDelegate,AMapNaviManagerDelegate,AMapNaviViewControllerDelegate,MAMapViewDelegate,IFlySpeechSynthesizerDelegate>
{
    CustomAnnotation *_ann;
    
    NSMutableArray *_dataImages;
    NSMutableArray *_dataArray;
    UITableView  *_tableView;
    NSMutableArray *_images;
    
    CGFloat lation;
    CGFloat longtion;
    
    UILabel *distance_label;
    
    
}

@property (nonatomic, strong) AMapNaviManager *naviManager;

@property (nonatomic, strong) AMapNaviViewController *naviViewController;

@property (nonatomic,strong) MAMapView *mapView;

@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;


@end

@implementation DetailedViewController

-(instancetype)initWithStore:(CustomAnnotation *)store{
    self = [super init];
    if (self) {
        _ann = store;
        _dataImages = [NSMutableArray array];
        if ([Utils isNull:_ann.pic1]) {
            [_dataImages addObject:_ann.pic1];
        }
        if ([Utils isNull:_ann.pic2]) {
            [_dataImages addObject:_ann.pic2];
        }
        if ([Utils isNull:_ann.pic3]) {
            [_dataImages addObject:_ann.pic3];
        }
        if ([Utils isNull:_ann.pic4]) {
            [ _dataImages addObject:_ann.pic4];
        }
        if ([Utils isNull:_ann.pic5]) {
            [_dataImages addObject:_ann.pic5];
        }
        //定位
        [self initMapView];
      
    }
    return self;
}

- (void)initNaviManager
{
    if (_naviManager == nil)
    {
        _naviManager = [[AMapNaviManager alloc] init];
        [_naviManager setDelegate:self];
    }
}

- (void)initNaviViewController{
    if (self.naviViewController == nil)
    {
        self.naviViewController = [[AMapNaviViewController alloc] initWithDelegate:self];
    }
    
    [self.naviViewController setDelegate:self];
}

- (void)initMapView
{
    if (_mapView == nil)
    {
        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    }
    [self.mapView setDelegate:self];
    
    [self.mapView setShowsUserLocation:YES];
    
}

- (void)initIFlySpeech
{
    if (self.iFlySpeechSynthesizer == nil)
    {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    _iFlySpeechSynthesizer.delegate = self;
}

#pragma mark ----managerDelegate
- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    //导航视图展示
    [_naviManager presentNaviViewController:_naviViewController animated:YES];
}

//导航视图被展示出来的回调函数
- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
{
    //调用startGPSNavi方法进行实时导航，调用startEmulatorNavi方法进行模拟导航
    [_naviManager startGPSNavi];
}

- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    
    [self.naviManager stopNavi];
    [self.iFlySpeechSynthesizer stopSpeaking];
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}

- (void)naviManager:(AMapNaviManager *)naviManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    [self initIFlySpeech];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_iFlySpeechSynthesizer startSpeaking:soundString];//soundString为导航引导语
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KviewColor;
    self.title = @"站点详情";
    
    [self creatTableView];
    
    [self creatRight];
    
}

#pragma mark -----创建有按钮
-(void)creatRight{
    UIBarButtonItem *right_btn = [[UIBarButtonItem alloc]initWithTitle:@"出发" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick:)];
    self.navigationItem.rightBarButtonItem = right_btn;
}



-(void)rightButtonClick:(UIBarButtonItem *)sender{
    
    [self initNaviManager];
    [self initNaviViewController];
    
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:_ann.coordinate.latitude  longitude:_ann.coordinate.longitude];

    NSArray *endPoints   = @[endPoint];
    
    //驾车路径规划（未设置途经点、导航策略为速度优先）
    [_naviManager calculateDriveRouteWithEndPoints:endPoints wayPoints:nil drivingStrategy:0];
    
}

-(void)creatTableView{
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    
    LoopPageView  *loopView = [[LoopPageView alloc]initWithFrame:CGRectMake(0, 0, KscreenWidth, 200)];
    loopView.images = _dataImages;
    loopView.alpha = 0.8;
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(40, 60, KscreenWidth-40, 60)];
    title.text = _ann.title;
    title.font = [UIFont systemFontOfSize:30];
    title.backgroundColor = [UIColor clearColor];
    distance_label = [[UILabel alloc]initWithFrame:CGRectMake(40, 150, KscreenWidth-40, 30)];
    distance_label.font = [UIFont systemFontOfSize:20];
    distance_label.backgroundColor = [UIColor clearColor];
    distance_label.text = @"正在定位";
    [loopView addSubview:title];
    [loopView addSubview:distance_label];
    _tableView.tableHeaderView = loopView;
    
    //描述
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, KscreenWidth-20, 100)];
    textView.font = [UIFont systemFontOfSize:18];
    if ([Utils isNull:_ann.describe]) {
        textView.text = _ann.describe;
    }
    textView.scrollEnabled = YES;    //当文字超过视图的边框时是否允许滑动，默认为“YES”
    textView.editable = NO;
    //重新调整textView的高度
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KscreenWidth, 100+20)];
    [view addSubview:textView];
    _tableView.tableFooterView = view;
    
    _dataArray = [NSMutableArray arrayWithArray:@[@[_ann.subtitle],@[_ann.userPhone],@[@"服务站"],@[@"简介"]]];
    _images = [NSMutableArray arrayWithArray:@[@[@"address"],@[@"phone"],@[@"charge"]]];
}
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation;{
    if (lation == 0 && longtion == 0) {
        MAMapPoint point1 = MAMapPointForCoordinate(userLocation.location.coordinate);
        MAMapPoint point2 = MAMapPointForCoordinate(_ann.coordinate);
        //2.计算距离
        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
        distance_label.text = [NSString stringWithFormat:@"%.2f公里",distance/1000];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storeCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"storeCell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 2) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(KscreenWidth-50, 7, 40, 30)];
        label.text = _ann.rnum;
        [cell.contentView addSubview:label];
    }
    if (!(indexPath.section == 3)) {
        NSString *str = _images[indexPath.section][indexPath.row];
        cell.imageView.image = [UIImage imageNamed:str];
        CGSize itemSize = CGSizeMake(25,26);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    cell.textLabel.text = _dataArray[indexPath.section][indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section ==1 && indexPath.row == 0) {
        UIWebView*callWebview = [[UIWebView alloc] init];
        NSString *str = [NSString stringWithFormat:@"tel:%@",_dataArray[indexPath.section][indexPath.row]];
        
        NSURL *telURL =[NSURL URLWithString:str];
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        //记得添加到view上
        [self.view addSubview:callWebview];
    }
}

#pragma mark - iFlySpeechSynthesizer Delegate

- (void)onCompleted:(IFlySpeechError *)error
{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
