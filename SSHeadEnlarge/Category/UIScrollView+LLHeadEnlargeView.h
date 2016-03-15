//
//  UIScrollView+LLHeadEnlargeView.h
//  SSHeadEnlarge
//
//  Created by sonny on 16/3/15.
//  Copyright © 2016年 sonny. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LLHeadEnlargeViewTarget <NSObject>

- (void)clickBannerWithIndex:(NSInteger)index;//0,1,2...

@end


@interface LLHeadEnlargeView : UIScrollView <UIScrollViewDelegate>

//实例
+ (instancetype)headEnlargeWithTarget:(id)target;//直接实现响应事件- (void)clickBannerWithIndex:(NSInteger)index;
/** target */
@property (nonatomic, weak) id clickTarget;
/** 父控件 */
@property (nonatomic, weak, readonly) UIScrollView *superScrolView;
//@property (nonatomic, strong) UIPageControl * imagePageContro;
@end




@interface UIScrollView (LLHeadEnlarge)

@property (nonatomic, strong) LLHeadEnlargeView *headEnlargeView;//底部View

@property (nonatomic, strong) NSString *saleTypeURL;//热卖类型URL
@property (nonatomic, strong) NSArray *imageNameArray;
@property (nonatomic, strong) NSArray *imageURLArray;

@end
