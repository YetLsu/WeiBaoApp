//
//  CustomAnnotation.m
//  NewPower
//
//  Created by 刘毕涛 on 16/2/16.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "CustomAnnotation.h"
#import "Utils.h"
@implementation CustomAnnotation

-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.coordinate = [Utils baiduTomars:CLLocationCoordinate2DMake([dic[@"pos_y"] floatValue], [dic[@"pos_x"]floatValue])];
        
        self.title = dic[@"title"];
        self.subtitle = dic[@"address"];
        self.mytype = [dic[@"cateid"] intValue];

        _pic1 =  [Utils isNull: dic[@"pic1"]] ?[NSString stringWithFormat:@"%@%@",KurlPhoto,dic[@"pic1"]]:@"";
        _pic2 =  [Utils isNull: dic[@"pic2"]] ?[NSString stringWithFormat:@"%@%@",KurlPhoto,dic[@"pic2"]]:@"";
        _pic3 =  [Utils isNull: dic[@"pic3"]] ?[NSString stringWithFormat:@"%@%@",KurlPhoto,dic[@"pic3"]]:@"";
        _pic4 =  [Utils isNull: dic[@"pic4"]] ?[NSString stringWithFormat:@"%@%@",KurlPhoto,dic[@"pic4"]]:@"";
        _pic5 =  [Utils isNull: dic[@"pic5"]] ?[NSString stringWithFormat:@"%@%@",KurlPhoto,dic[@"pic5"]]:@"";
        
        _describe = dic[@"description"];
        _userName = dic[@"username"];
        _userPhone = dic[@"userphone"];
        _regtime = dic[@"regtime"];
        _isdel = [dic[@"isdel"] integerValue];
        _isnew = [dic[@"isnew"] integerValue];
        _rnum = [NSString stringWithFormat:@"%@个",dic[@"rnum"]];
        
    }
    return self;
}

@end
