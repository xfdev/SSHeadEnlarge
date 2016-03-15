//
//  UIScrollView+LLHeadEnlargeView.m
//  SSHeadEnlarge
//
//  Created by sonny on 16/3/15.
//  Copyright © 2016年 sonny. All rights reserved.
//

#import "UIScrollView+LLHeadEnlargeView.h"

#import <objc/runtime.h>

#define imageHeight SCREEN_WIDTH/9*5 // 9 比 5
#define kPageControlTag 60
#define kSaleImageViewTag 61
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@implementation LLHeadEnlargeView

+ (instancetype)headEnlargeWithTarget:(id)target {
    
    LLHeadEnlargeView *headView = [[self alloc] init];
    headView.clickTarget = target;
    headView.alwaysBounceHorizontal = YES;
    headView.showsHorizontalScrollIndicator = NO;
    headView.pagingEnabled = YES;
    headView.transform = CGAffineTransformIdentity;
    return headView;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    //如果不是UIScrollView则return
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    //父控件旧的监听
    [self removeObservers];
    
    if (newSuperview) {
        //记录父控件
        _superScrolView = (UIScrollView *)newSuperview;
        
        //添加监听
        [self addObservers];
    }
}

///监听
- (void)addObservers {
    [self.superScrolView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeObservers {
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        //目前拖动到的状态
        CGFloat offsetY = self.superScrolView.contentOffset.y;
        if (offsetY < -imageHeight) {
            //下拉状态 -200 -> -300
            CGRect rect = self.frame;
            rect.origin.y = offsetY;
            rect.size.height = -offsetY;
            self.frame = rect;
            //sale
            //            UIImageView *sale = (UIImageView *)[self.superScrolView viewWithTag:kSaleImageViewTag];
            //            CGRect saleR = sale.frame;
            //            saleR.origin.y = offsetY + 20;
            //            sale.frame = saleR;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //更新UIPageControl的当前页
    CGPoint offset = scrollView.contentOffset;
    UIPageControl *pageCtl = (UIPageControl *)[self.superScrolView viewWithTag:kPageControlTag];
    [pageCtl setCurrentPage:lroundf(offset.x / CGRectGetWidth(scrollView.frame))];
}
//没有跳转
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//
//    CGPoint point = [[touches anyObject] locationInView:self];
//    NSInteger index = point.x / SCREEN_WIDTH;
//    if (_clickTarget && [_clickTarget respondsToSelector:@selector(clickBannerWithIndex:)]) {
//        [_clickTarget clickBannerWithIndex:index];
//    }
//}
@end

//UIScrollView categary...
@implementation UIScrollView (LLHeadEnlarge)

static const char LLHeadEnlargeViewKey = '\0';
- (void)setHeadEnlargeView:(LLHeadEnlargeView *)headEnlargeView {
    
    if (headEnlargeView != self.headEnlargeView) {
        [self.headEnlargeView removeFromSuperview];
        [self addSubview:headEnlargeView];
        
        headEnlargeView.frame = CGRectMake(0, -imageHeight, SCREEN_WIDTH, imageHeight);
        //        [headEnlargeView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(self.top);
        //            make.left.equalTo(self.left);
        //            make.right.equalTo(self.right);
        //            make.height.equalTo(imageHeight);
        //        }];
        
        [self setContentInset:UIEdgeInsetsMake(imageHeight, 0, 0, 0)];
        [self setContentOffset:CGPointMake(0, -imageHeight) animated:NO];
        
        [self willChangeValueForKey:@"headEnlargeView"];
        objc_setAssociatedObject(self, &LLHeadEnlargeViewKey, headEnlargeView, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"headEnlargeView"];
    }
}
- (LLHeadEnlargeView *)headEnlargeView {
    return objc_getAssociatedObject(self, &LLHeadEnlargeViewKey);
}
- (void)setSaleTypeURL:(NSString *)saleTypeURL {
    //去掉热卖类型
    //    if (saleTypeURL.length) {
    //        UIImageView *sale = [UIImageView new];
    //        [sale setImageWithURL:[NSURL URLWithString:saleTypeURL]];
    //        sale.tag = kSaleImageViewTag;
    //        [self addSubview:sale];
    //
    //        sale.frame = CGRectMake(15, -imageHeight + 20, 35, 35);
    
    //        [sale mas_makeConstraints:^(MASConstraintMaker *make) {
    //            make.top.equalTo(self.top).offset(-imageHeight + 20);
    //            make.left.equalTo(self.left).offset(15);
    //        }];
    //    }
}
- (NSString *)saleTypeURL {
    return self.saleTypeURL;
}

- (void)setImageNameArray:(NSArray *)imageNameArray {
    
    if (![imageNameArray isKindOfClass:[NSArray class]]) {
        return;
    }
    if (!imageNameArray.count) {
        self.contentInset = UIEdgeInsetsZero;
        return;
    }
    UIView *contentView = UIView.new;
    [self.headEnlargeView addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.headEnlargeView);
        make.height.equalTo(self.headEnlargeView);
    }];
    
    UIView *lastView = nil;
    CGFloat imageWidth = CGRectGetWidth(self.headEnlargeView.frame);
    
    for (NSInteger i = 0; i < imageNameArray.count; i++) {
        
        NSString *imageName = [imageNameArray objectAtIndex:i];
        
        UIImageView *imgView = [UIImageView new];
        imgView.image = [UIImage imageNamed:imageName];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.tag = 10+i;
        imgView.clipsToBounds = YES;
        [contentView addSubview:imgView];
        
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentView.top);
            make.left.equalTo(lastView ? lastView.right : @0);
            make.width.equalTo(imageWidth);
            make.height.equalTo(contentView.height);
        }];
        lastView = imgView;
    }
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lastView.right);
    }];
    
//    UIImageView * shadowImageView = [[UIImageView alloc]init];
//    shadowImageView.image         = [UIImage imageNamed:@"v_index_shadow"];
//    shadowImageView.contentMode   = UIViewContentModeScaleAspectFill;
//    shadowImageView.clipsToBounds = YES;
//    [self.headEnlargeView addSubview:shadowImageView];
//    [self.headEnlargeView bringSubviewToFront:shadowImageView];
//    [shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.headEnlargeView);
//    }];
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, -40, 0, 40)];
    pageControl.numberOfPages = imageNameArray.count;
    [pageControl addTarget:self action:@selector(clickPageControl:) forControlEvents:UIControlEventTouchUpInside];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.tag = kPageControlTag;
    [self addSubview:pageControl];
    
    [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(bannerMove) userInfo:nil repeats:YES];
}
- (NSArray *)imageNameArray {
    return self.imageNameArray;
}

- (void)setImageURLArray:(NSArray *)imageURLArray {
    
    
}
- (NSArray *)imageURLArray {
    return self.imageURLArray;
}

- (void)clickPageControl:(UIPageControl *)pageCtl {
    NSInteger page = pageCtl.currentPage;
    [self.headEnlargeView setContentOffset:CGPointMake(CGRectGetWidth(self.headEnlargeView.frame)*page, 0) animated:YES];
}

- (void)bannerMove {
    UIPageControl *pageCtl = (UIPageControl *)[self viewWithTag:kPageControlTag];
    NSInteger pages = pageCtl.numberOfPages;
    if (pages <= 1) {
        return;
    }
    
    NSInteger page = pageCtl.currentPage;
    if (page < pages - 1) {
        pageCtl.currentPage ++;
    } else if (page == pages - 1) {
        pageCtl.currentPage = 0;
    }
    [self.headEnlargeView setContentOffset:CGPointMake(CGRectGetWidth(self.headEnlargeView.frame)*pageCtl.currentPage, 0) animated:YES];
}

@end
