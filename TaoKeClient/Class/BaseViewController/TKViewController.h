//
//  TKViewController.h
//  TaoKeClient
//
//  Created by YueWen on 2017/10/21.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 淘客的基础控制器
@interface TKViewController : UIViewController

/// 在init方法中加载自己的属性
- (void)loadPropertysAtInitialization NS_REQUIRES_SUPER;


#pragma mark - *************** test ***************
/// 默认不做任何操作，用于测试
- (void)doNothing;

@end

NS_ASSUME_NONNULL_END
