//
//  TBLoopWork.h
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBLoopWorkUnit.h"
#import "TBLoopDistributer.h"
#import "TBLoopDefinition.h"

/*
 
 轮询任务管理类，管理着当前任务下的所有的依赖和回调block
 
 */

@interface TBLoopWork : NSObject

// 依赖和回调
@property (nonatomic, strong, readonly) NSMutableArray <TBLoopWorkUnit *> *units;

// 轮询的任务
@property (nonatomic, copy, readonly) TBLoopWorkBlock work;

// 轮询频率
@property (nonatomic, assign, readonly) NSTimeInterval interval;

// 任务的唯一标识
@property (nonatomic, copy, readonly) NSString *identifier;

// 是否在执行
@property (nonatomic, assign, readonly) BOOL executing;

+ (instancetype)work:(TBLoopWorkBlock)work interval:(NSTimeInterval)interval identifier:(NSString *)identifier;

/**
 执行轮询的任务

 @return YES - 成功执行， NO - 执行失败，可以移除该任务
 */
- (BOOL)working;

@end

