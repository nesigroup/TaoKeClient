//
//  NSArray+TKExtension.h
//  XiaoNongDingClient
//
//  Created by YueWen on 2017/6/22.
//  Copyright © 2017年 ryden. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 泛型数组使用
@interface NSArray<__covariant ObjectType> (TKExtension)

/// 数组转换的map函数
- (NSArray *)tk_detailMap:(id(^)(ObjectType,NSInteger))mapHandler;
- (NSArray *)tk_map:(id(^)(ObjectType))mapHander;



/// 数组过滤器的filter函数
- (NSArray *)tk_detailFilter:(BOOL(^)(ObjectType,NSInteger))filterHandler;
- (NSArray *)tk_filter:(BOOL(^)(ObjectType))filterHandler;


/// 数组变换的reduce函数
- (NSArray *)tk_detailReduce:(NSArray *)initial
                reduceHandler:(NSArray *(^)(NSArray *,id,NSInteger))reduceHandler;
- (NSArray *)tk_reduce:(NSArray *)initial
          reduceHandler:(NSArray *(^)(NSArray *,id))reduceHandler;



/// 逆序数组
- (NSArray <ObjectType> *)tk_revert;


@property (nonatomic, strong, nullable, readonly)ObjectType tk_safeFirstObject;

/// 获得object的方法
- (nullable ObjectType)tk_safeObjectAtIndex:(NSInteger)index;


/// 获得逆序的方法
- (nullable ObjectType)tk_revertObjectAtIndex:(NSInteger)index;

@end



NS_ASSUME_NONNULL_END
