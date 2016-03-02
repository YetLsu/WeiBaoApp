//
//  GuidaceViewController.m
//  NewPower
//
//  Created by 刘毕涛 on 16/1/19.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "GuidaceViewController.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapNaviKit/MAMapKit.h>

#import <AFNetworking.h>
#import "Utils.h"
#import "CustomAnnotation.h"

#import "iflyMSC/IFlySpeechError.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"

@interface GuidaceViewController ()<UIGestureRecognizerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,AMapNaviManagerDelegate,AMapNaviViewControllerDelegate,MAMapViewDelegate,IFlySpeechSynthesizerDelegate>
{
    __weak IBOutlet UITextField *_start;
    __weak IBOutlet UITextField *_end;
    __weak IBOutlet UITableView *_tableView;

    UITextField *_currend;

    NSMutableArray *_dataArray;
 
}

@property (nonatomic, strong) AMapNaviManager *naviManager;

@property (nonatomic, strong) AMapNaviViewController *naviViewController;

@property (nonatomic,strong) MAMapView *mapView;

@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;

@end

@implementation GuidaceViewController

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
#pragma mark ---- 界面初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KviewColor;
    
    //初始化地图
    [self initMapView];
    
    _start.tag = 1;
    _end.tag = 2;
   
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _dataArray = [NSMutableArray array];
    
    _currend = [[UITextField alloc]init];

    [self setUpSubviews];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handle) name:UITextFieldTextDidChangeNotification object:nil];
    
}

-(void)handle{
    if ([_start isFirstResponder]) {
        [self requestWith:_start.text];
    }else{
        [self requestWith:_end.text];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setUpSubviews{
    _start.delegate = self;
    [_start becomeFirstResponder];
    _end.delegate = self;
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
    //导航键
    UIBarButtonItem *right_btn = [[UIBarButtonItem alloc]initWithTitle:@"导航 " style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick:)];
    self.navigationItem.rightBarButtonItem = right_btn;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self requestWith:textField.text];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"guideCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"guideCell"];
    }
       CustomAnnotation *annotation = _dataArray[indexPath.row];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"4"];
        cell.textLabel.text = annotation.title;
    }else{
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gas%d",annotation.mytype]];
        cell.textLabel.text = annotation.title;
        cell.detailTextLabel.text = annotation.subtitle;
    }
    CGSize itemSize = CGSizeMake(23,30);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CustomAnnotation *ann = _dataArray[indexPath.row];
    _currend.text = ann.title;
    if (_currend.tag == 1) {
        _startCLL = ann.coordinate;
    }else{
        _endCLL = ann.coordinate;
    }
}

-(void)rightButtonClick:(UIBarButtonItem *)sender{
    
    [self initNaviManager];
    [self initNaviViewController];
    
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:_startCLL.latitude longitude:_startCLL.longitude];
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:_endCLL.latitude  longitude:_endCLL.longitude];
    
    NSArray *startPoints = @[startPoint];
    NSArray *endPoints   = @[endPoint];

    //驾车路径规划（未设置途经点、导航策略为速度优先）
    [_naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:0];

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
                [_dataArray addObject:point];
            }
            CustomAnnotation *point = [[CustomAnnotation alloc]init];
            point.coordinate = CLLocationCoordinate2DMake(_mapView.userLocation.location.coordinate.latitude, _mapView.userLocation.location.coordinate.longitude);
            point.title = @"现在的位置";
            [_dataArray insertObject:point atIndex:0];
            [_tableView reloadData];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        
    }];
}


//确定这个手势是否可以实现
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //判断这个账号和密码控件中是否都是第一响应者
    if (![_start isFirstResponder] && ![_end isFirstResponder]) {
        //都不是第一响应者的时候
        return NO;
    }
    return YES;
}
#pragma mark - iFlySpeechSynthesizer Delegate

- (void)onCompleted:(IFlySpeechError *)error
{
}



#pragma mark - 键盘操作
//隐藏键盘栏
- (void)hidenKeyboard
{
    if ([_start isFirstResponder]) {
        _currend = _start;
        [_start resignFirstResponder];
    }else{
        _currend = _end;
         [_end resignFirstResponder];
    }
    
   
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
