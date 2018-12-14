//
//  TBLoopTimer.h
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBLoopWork.h"
#import <GCDTimer/GCDTimer.h>

/*
 定时器管理类，管理着当前频率的定时器和对应的当前频率下的所有的轮询任务
 */

@interface TBLoopTimer : NSObject

@property (nonatomic, strong, readonly) GCDTimer *timer;
@property (nonatomic, assign, readonly) NSTimeInterval interval;
@property (nonatomic, strong, readonly) NSMutableDictionary <NSString *, TBLoopWork *> *works;

+ (TBLoopTimer *)timerWithInterval:(NSTimeInterval)interval block:(void (^)(void))block;

- (void)invalidate;

@end

