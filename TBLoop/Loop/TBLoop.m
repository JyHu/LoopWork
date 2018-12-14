//
//  TBLoop.m
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import "TBLoop.h"
#import "TBLoopTimer.h"
#import "TBLoopWork.h"
#import "TBLoopWorkUnit.h"
#import "TBLoopDistributer.h"
#import "TBLoopLogger.h"

@interface TBLoop()

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, TBLoopTimer *> *timerCaches;

@end

@implementation TBLoop

+ (instancetype)defaultLoop {
    static TBLoop *loop = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loop = [[TBLoop alloc] init];
    });
    return loop;
}

#pragma mark - operating

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

/**
 添加一个轮询任务，如果添加的参数不合法，将会添加失败
 
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
        response:(TBLoopCallbackBlock)response {
    
    NSAssert(dependence != nil, @"依赖不能为空，如果不需要依赖，请使用 `loopWork:interval:identifier:response:`");
    return [self loopWork:work interval:interval dependence:dependence identifier:identifier response:response manualControl:NO];
}

- (NSString *)loopWork:(TBLoopWorkBlock)work interval:(NSTimeInterval)interval identifier:(NSString *)identifier response:(TBLoopCallbackBlock)response {
    return [self loopWork:work interval:interval dependence:nil identifier:identifier response:response manualControl:YES];
}

- (NSString *)loopWork:(TBLoopWorkBlock)work
        interval:(NSTimeInterval)interval
      dependence:(id)dependence
      identifier:(NSString *)identifier
        response:(TBLoopCallbackBlock)response
   manualControl:(BOOL)manualControl {
    
    // 安全判断
    NSAssert(work != nil, @"任务不能为空");
    NSAssert(interval > 0, @"轮询频率不能低于0");
    NSAssert(identifier != nil, @"任务的key不能为空");
    NSAssert(response != nil, @"response不能为空");
    
    // 找到所在定时器
    TBLoopTimer *timerCache = [self timerCacheWithInterval:interval];
    
    // 找到所在的任务
    TBLoopWork *loopWork = [timerCache.works objectForKey:identifier];
    
    if (!loopWork) {
        // 如果没有所在的任务，那么就创建一个
        loopWork = [TBLoopWork work:work interval:interval identifier:identifier];
        [timerCache.works setObject:loopWork forKey:identifier];
    }
    
    // 缓存依赖，不做唯一性的过滤判断
    TBLoopWorkUnit *unit = [TBLoopWorkUnit unitWithCallback:[response copy] dependence:dependence];
    unit.manualControl = manualControl;
    [loopWork.units addObject:unit];
    
    __TBLoopLogger(@"Add unit successed in [work : %@] [timer : %.2f], now have %ld units in current work.", identifier, interval, loopWork.units.count);
    
    [self timerCountDebugLog];

    // 立马执行一下轮询，保证外面第一时间拿到数据
    [self performLoopAction:interval];
    
    return unit.unitIdentifier;;
}

#pragma clang diagnostic pop

/**
 根据添加监听时的唯一id来移除监听
 
 @param uid 添加loopWor时的返回值
 */
- (void)removeCallbackWithUnitID:(NSString *)uid {
    if (uid == nil) {
        return;
    }
    
    @synchronized (self.timerCaches) {
        BOOL exits = NO;
        
        for (NSNumber *timerKey in self.timerCaches.allKeys) {
            TBLoopTimer *timer = [self.timerCaches objectForKey:timerKey];
            for (NSString *workIdentifier in timer.works.allKeys) {
                TBLoopWork *loopWork = [timer.works objectForKey:workIdentifier];
                for (TBLoopWorkUnit *unit in loopWork.units) {
                    if ([unit.unitIdentifier isEqualToString:uid]) {
                        __TBLoopLogger(@"Remove [unit : %@] successed, in [work : %@], [timer : %@]", unit.unitIdentifier, workIdentifier, timerKey);
                        [loopWork.units removeObject:unit];
                        exits = YES;
                        break;
                    }
                }
                
                if (exits) {
                    if (loopWork.units.count == 0) {
                        __TBLoopLogger(@"Remove [work : %@] in [timer : %@]", workIdentifier, timerKey);
                        [timer.works removeObjectForKey:workIdentifier];
                    }
                    break;
                }
            }
            
            if (exits) {
                [self justifyTimerCache:timer];
                break;
            }
        }
    }
    
    [self timerCountDebugLog];
}

/**
 根据给定的identifier移除所有频率下指定的任务
 
 @param identifier 任务的唯一标识
 */
- (void)removeLoopWorkWithIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return;
    }
    
    @synchronized (self.timerCaches) {
        for (NSNumber *timerKey in self.timerCaches.allKeys) {
            TBLoopTimer *timerCache = [self.timerCaches objectForKey:timerKey];
            if (timerCache) {
                [timerCache.works removeObjectForKey:identifier];
                [self justifyTimerCache:timerCache];
            }
        }
    }
    
    [self timerCountDebugLog];
}

/**
 根据指定的依赖，移除所有相关的callback
 
 @param dependence 依赖
 */
- (void)removeLoopDependence:(id)dependence {
    if (dependence == nil) {
        return;
    }
    
    @synchronized (self.timerCaches) {
        for (NSNumber *timerKey in self.timerCaches.allKeys) {
            TBLoopTimer *timerCache = [self.timerCaches objectForKey:timerKey];
            for (NSString *workKey in timerCache.works.allKeys) {
                [self removeDependence:dependence inWork:[timerCache.works objectForKey:workKey] inTimer:timerCache workIdentifier:workKey];
            }
            
            [self justifyTimerCache:timerCache];
        }
    }
    
    [self timerCountDebugLog];
}

/**
 移除指定的定时器和其下的所有任务
 
 @param interval 定时器的频率
 */
- (void)removeLoopWorkWithInterval:(NSTimeInterval)interval {
    if (interval <= 0) {
        return;
    }
    @synchronized (self.timerCaches) {
        TBLoopTimer *timerCache = [self.timerCaches objectForKey:@(interval)];
        [timerCache.works removeAllObjects];
        [self justifyTimerCache:timerCache];
    }
    
    [self timerCountDebugLog];
}

/**
 移除指定的任务
 
 @warning 如果某个字段为空或者不合法，将会忽略这个字段，会移除同级的所有任务
 
 @param interval 任务所在的频率
 @param identifier 任务的标识
 @param dependence 依赖
 */
- (void)removeLoopWorkWithInterval:(NSTimeInterval)interval identifier:(NSString *)identifier dependence:(id)dependence {
    @synchronized (self.timerCaches) {
        // 如果时间不合法，那就去查所有定时器下的任务和依赖
        if (interval <= 0) {
            // 如果只有依赖有效，那就移除所有此依赖相关的callback
            if (identifier == nil && dependence != nil) {
                [self removeLoopDependence:dependence];
            }
            // 如果只有任务key有效，那么移除这个任务和所有的callback
            else if (identifier != nil && dependence == nil) {
                [self removeLoopWorkWithIdentifier:identifier];
            }
            // 如果任务key和依赖都有效，那么轮询所有的依赖，并移除所有对应的callback
            else if (identifier != nil && dependence != nil) {
                // 先遍历所有的定时器
                for (NSNumber *timerKey in self.timerCaches.allKeys) {
                    TBLoopTimer *timerCache = [self.timerCaches objectForKey:timerKey];
                    [self removeDependence:dependence inWork:[timerCache.works objectForKey:identifier] inTimer:timerCache workIdentifier:identifier];
                }
            }
        } else {
            // 找到指定的定时器
            TBLoopTimer *timerCache = [self.timerCaches objectForKey:@(interval)];
            if (timerCache) {
                // 如果只有任务key有效，那就移除当前定时器下的这个任务
                if (identifier != nil && dependence == nil) {
                    [timerCache.works removeObjectForKey:identifier];
                }
                // 如果只有依赖有效，那么就移除当前定时器下所有相同的依赖callback
                else if (identifier == nil && dependence != nil) {
                    for (NSString *workKey in timerCache.works.allKeys) {
                        [self removeDependence:dependence inWork:[timerCache.works objectForKey:workKey] inTimer:timerCache workIdentifier:workKey];
                    }
                }
                // 如果任务key和依赖都有效，那么就去查指定的依赖并移除
                else if (identifier != nil && dependence != nil) {
                    [self removeDependence:dependence inWork:[timerCache.works objectForKey:identifier] inTimer:timerCache workIdentifier:identifier];
                }
                
                [self justifyTimerCache:timerCache];
            }
        }
    }
    
    [self timerCountDebugLog];
}

/**
 移除所有的定时器、轮询任务和依赖等
 */
- (void)removeAllLoopWorks {
    @synchronized (self.timerCaches) {
        // 遍历销毁所有的定时器
        for (NSNumber *timerKey in self.timerCaches.allKeys) {
            TBLoopTimer *timerCache = [self.timerCaches objectForKey:timerKey];
            [timerCache.works removeAllObjects];
            [self justifyTimerCache:timerCache];
        }
    }
    
    __TBLoopLogger(@"remove all timer successed");
}

/**
 是否需要调试日志输出
 
 @param enable 默认为yes
 */
+ (void)debugLogEnable:(BOOL)enable {
    [TBLoopLogger debugLogEnable:enable];
}

#pragma mark - action

/**
 执行轮询任务

 @param interval 轮询频率
 */
- (void)performLoopAction:(NSTimeInterval)interval {
    @synchronized (self.timerCaches) {
        // 首先拿到当前频率下的定时器
        TBLoopTimer *timerCache = [self.timerCaches objectForKey:@(interval)];
        if (timerCache) {
            // 如果存在，那么遍历其下的所有任务并执行
            for (NSString *workIdentifier in timerCache.works.allKeys) {
                if ([[timerCache.works objectForKey:workIdentifier] working]) {
                    __TBLoopLogger(@"Loop action [timer : %f], [work : %@] is working.", interval, workIdentifier);
                } else {
                    [timerCache.works removeObjectForKey:workIdentifier];
                    __TBLoopLogger(@"Loop action [timer : %f], [work : %@] invalid and removed, because there is no dependence or callback block.", interval, workIdentifier);
                }
            }
            
            [self justifyTimerCache:timerCache];
        }
    }
}

#pragma mark - helper

- (void)timerCountDebugLog {
    if (self.timerCaches.count == 0) {
        __TBLoopLogger(@"There is no timers running.");
    } else {
        __TBLoopLogger(@"%ld timers running now", self.timerCaches.count);
    }
}

// 辅助移除方法
- (void)removeDependence:(id)dependence inWork:(TBLoopWork *)loopWork inTimer:(TBLoopTimer *)timer workIdentifier:(NSString *)identifier {
    if (loopWork) {
        NSMutableArray *invalidDependences = [[NSMutableArray alloc] initWithCapacity:loopWork.units.count];
        
        // 如果任务有效，那么遍历所有的依赖
        for (TBLoopWorkUnit *unit in loopWork.units) {
            // 如果是相同的依赖，那就移除
            if ([unit.dependence isEqual:dependence]) {
                [invalidDependences addObject:unit];
                __TBLoopLogger(@"Remove dependence");
            }
        }
        
        [loopWork.units removeObjectsInArray:invalidDependences];
        
        if (loopWork.units.count == 0 && timer) {
            [timer.works removeObjectForKey:identifier];
            [self justifyTimerCache:timer];
            
            __TBLoopLogger(@"Remove works : %@", identifier);
        }
    }
}

/**
 根据给定的时间来获取一个对应的定时器

 @param interval 轮询的频率
 @return 定时器
 */
- (TBLoopTimer *)timerCacheWithInterval:(NSTimeInterval)interval {
    TBLoopTimer *timerCache = [self.timerCaches objectForKey:@(interval)];
    if (timerCache == nil) {
        __weak typeof(self) weakSelf = self;
        timerCache = [TBLoopTimer timerWithInterval:interval block:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf performLoopAction:interval];
            });
        }];
        [self.timerCaches setObject:timerCache forKey:@(interval)];
        __TBLoopLogger(@"Create timer successed with interval : %.2f !", interval);
    } else {
        __TBLoopLogger(@"Find a timer with interval : %.2f .", interval);
    }
    
    return timerCache;
}

/**
 校验定时器是否有效

 @param timerCache 定时器
 */
- (void)justifyTimerCache:(TBLoopTimer *)timerCache {
    if (timerCache != nil && timerCache.works.count == 0) {
        [timerCache invalidate];
        [self.timerCaches removeObjectForKey:@(timerCache.interval)];
        
        __TBLoopLogger(@"Remove timer %.2f because there is no works.", timerCache.interval);
    }
}


#pragma mark - getter

- (NSMutableDictionary<NSNumber *,TBLoopTimer *> *)timerCaches {
    if (!_timerCaches) {
        _timerCaches = [[NSMutableDictionary alloc] init];
    }
    return _timerCaches;
}

@end
