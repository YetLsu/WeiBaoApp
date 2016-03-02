//
//  LoopPageView.m
//  NewPower
//
//  Created by 刘毕涛 on 16/2/22.
//  Copyright © 2016年 浙江蚁窝投资管理有限公司. All rights reserved.
//

#import "LoopPageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LoopPageView ()<UIScrollViewDelegate>
@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,weak)  UIPageControl *pageControl;
@property (nonatomic,weak)  NSTimer *timer;

@end

@implementation LoopPageView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        self.scrollView = scrollView;
        [self addSubview:scrollView];
        for (NSUInteger i = 0; i < 3; i++) {
            UIImageView  *imageView = [[UIImageView alloc]init];
            [self.scrollView addSubview:imageView];
        }
        UIPageControl *pageV = [[UIPageControl alloc]init];
        self.pageControl = pageV;
        [self addSubview:pageV];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    self.scrollView.frame = CGRectMake(0, 0, w, h);
    self.pageControl.frame = CGRectMake(0, h - 37, w, 37);
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIImageView *img = (UIImageView *)obj;
            img.frame = CGRectMake(idx * w, 0, w, h);
        }];
    self.scrollView.contentSize = CGSizeMake(3 * self.frame.size.width, 0);
    self.pageControl.numberOfPages = self.images.count;
    self.pageControl.currentPage = 0;
    
    [self updateImage];
}

#pragma mark <UIScrollViewDelegate>
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self stopTimer];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    [self startTimer];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateImage];
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateImage];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = 0;
    CGFloat minDistance = MAXFLOAT;
    for (int i = 0; i<self.scrollView.subviews.count; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        CGFloat distance = 0;

    distance = ABS(imageView.frame.origin.x - scrollView.contentOffset.x);
        if (distance < minDistance) {
            minDistance = distance;
            page = imageView.tag;
        }
    }
    self.pageControl.currentPage = page;
}
#pragma mark -
#pragma mark private methods
- (void)updateImage
{
    for (NSUInteger i = 0; i < self.scrollView.subviews.count; i++) {
        UIImageView *imagV = self.scrollView.subviews[i];
        NSInteger index = self.pageControl.currentPage;
        if (i == 0) {
            index--;
        }else if(i == 2)
        {
            index++;
        }
        if (index < 0) {
            index = self.pageControl.numberOfPages - 1;
        }else if(index >= self.pageControl.numberOfPages )
        {
            index = 0;
        }
        imagV.tag = index;
        [imagV sd_setImageWithURL: [NSURL URLWithString:_images[index]] placeholderImage:[UIImage imageNamed:@"holderImage"]];
    }
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    
}
- (void)next
{
        [self.scrollView setContentOffset:CGPointMake(2 * self.scrollView.frame.size.width, 0) animated:YES];
    
}
//- (void)startTimer
//{
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(next) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
//}
//-(void)stopTimer
//{
//    [self.timer invalidate];
//    self.timer = nil;
//}

#pragma mark -
#pragma mark setter and getter

-(void)setImageNames:(NSArray *)imageNames
{
    _images = imageNames;
//    [self startTimer];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
