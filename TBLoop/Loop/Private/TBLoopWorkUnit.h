//
//  TBLoopWorkUnit.h
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBLoopDefinition.h"


/*
 
 依赖和回调的管理类
 
 */

@interface TBLoopWorkUnit : NSObject

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

@property (nonatomic, weak, readonly) id dependence;
@property (nonatomic, copy, readonly) TBLoopCallbackBlock callback;
@property (nonatomic, assign, readonly) BOOL isInvalid;
@property (nonatomic, assign) BOOL manualControl;

@property (nonatomic, copy, readonly) NSString *unitIdentifier;

+ (instancetype)unitWithCallback:(TBLoopCallbackBlock)callback;
+ (instancetype)unitWithCallback:(TBLoopCallbackBlock)callback dependence:(id)dependence;

#pragma clang diagnostic pop

@end
