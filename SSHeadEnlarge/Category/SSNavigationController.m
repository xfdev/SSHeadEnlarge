//
//  SSNavigationController.m
//  someDemo
//
//  Created by sonny on 15/10/4.
//  Copyright © 2015年 sonny. All rights reserved.
//

#import "SSNavigationController.h"

@interface UINavigationController (SSNavigationControllerPrivate)

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

//____________________________________这个类的开始_____________________________
@interface SSNavigationController ()

@property (nonatomic, assign) BOOL shouldIgnorePushingViewControllers;

@end

@implementation SSNavigationController

#pragma mark -
#pragma mark Push
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (!self.shouldIgnorePushingViewControllers) {
        
        [super pushViewController:viewController animated:animated];
    }
    self.shouldIgnorePushingViewControllers = YES;
}

#pragma mark - set View Controllers
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    
    if (!self.shouldIgnorePushingViewControllers) {
        
        [super setViewControllers:viewControllers animated:animated];
    }
    self.shouldIgnorePushingViewControllers = YES;
}

#pragma mark - Private API
// This is confirmed to be App Store safe.
// If you feel uncomfortable to use Private API, you could also use the delegate method navigationController:didShowViewController:animated:.
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    self.shouldIgnorePushingViewControllers = NO;
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
