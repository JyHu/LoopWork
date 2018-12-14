//
//  TBLoopDefinition.h
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#ifndef TBLoopDefinition_h
#define TBLoopDefinition_h

#import "TBLoopDistributer.h"

/**
 轮询的任务

 @param distributer 任务执行结果的分发者
 */
typedef void (^TBLoopWorkBlock)(TBLoopDistributer *distributer);

#pragma clang diagnostic push
#pragma clang diagnostic ignore "-Wstrict-prototypes"

/**
 任务结果的回调，变参，参数跟distributer分发的结果一一对应
 */
typedef void (^TBLoopCallbackBlock) ();

#pragma clang diagnostic pop

#endif /* TBLoopDefinition_h */
