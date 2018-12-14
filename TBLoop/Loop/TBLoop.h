//
//  TBLoop.h
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBLoopDistributer.h"
#import "TBLoopDefinition.h"

@interface TBLoop : NSObject

/**
 默认的单例方法
 */
+ (instancetype)defaultLoop;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

/**
 添加一个轮询任务，如果添加的参数不合法，将会添加失败
 
 所有的轮询定时器都在一个异步线程执行，轮询的任务(work)会在主线程中调用

 @param work 需要轮询的任务，相同的任务标识下只会有一个任务存在和执行
 @param interval 轮询的频率
 @param dependence 任务的依赖
 @param identifier 任务的标识
 @param response 轮询的返回结果，变参，与work里返回的数据对应
 @return resposne的全局唯一标识，可以以此来移除数据的监听，如果任务添加失败，将会返回nil
 
 关于dependence：
 
 对任务回调添加依赖，这个依赖将会被弱引用，当一个任务的所以依赖都被释放掉后，这个任务也会被释放，
 然后还会检查轮询定时器的任务数，当没有任务的时候，这个定时器也会被销毁。
 
 如果不添加依赖，那么这个callback需要调用者手动的移除，或者将回调的callback置为nil，这个callback同样的会被移除。
 
 注意，不管添加不添加依赖，所有相同identifier的callback都会添加在一个任务下，所以，对于没有依赖的回调一定要注意主动销毁。
 */
- (NSString *)loopWork:(TBLoopWorkBlock)work
              interval:(NSTimeInterval)interval
            dependence:(id)dependence
            identifier:(NSString *)identifier
              response:(TBLoopCallbackBlock)response;

- (NSString *)loopWork:(TBLoopWorkBlock)work
              interval:(NSTimeInterval)interval
            identifier:(NSString *)identifier
              response:(TBLoopCallbackBlock)response;

#pragma clang diagnostic pop

/**
 根据添加监听时的唯一id来移除监听

 @param uid 添加loopWor时的返回值
 */
- (void)removeCallbackWithUnitID:(NSString *)uid;

/**
 根据给定的identifier移除所有频率下指定的任务
 
 @param identifier 任务的唯一标识
 */
- (void)removeLoopWorkWithIdentifier:(NSString *)identifier;

/**
 根据指定的依赖，移除所有相关的callback
 
 @param dependence 依赖
 */
- (void)removeLoopDependence:(id)dependence;

/**
 移除指定的定时器和其下的所有任务
 
 @param interval 定时器的频率
 */
- (void)removeLoopWorkWithInterval:(NSTimeInterval)interval;

/**
 移除指定的任务，这个方法不做参数的校验
 
 @warning 如果某个字段为空或者不合法，将会忽略这个字段，会移除同级的所有任务
 
 @param interval 任务所在的频率
 @param identifier 任务的标识
 @param dependence 依赖
 */
- (void)removeLoopWorkWithInterval:(NSTimeInterval)interval
                        identifier:(NSString *)identifier
                        dependence:(id)dependence;

/**
 移除所有的定时器、轮询任务和依赖等
 */
- (void)removeAllLoopWorks;

/**
 是否需要调试日志输出

 @param enable 默认为yes
 */
+ (void)debugLogEnable:(BOOL)enable;

@end

