//
//  TBLoopDistributer+TBPrivate.h
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import "TBLoopDistributer.h"

// 留给work使用的，用于传递数据回去
@protocol TBLoopDistributerDelegate <NSObject>
@required
- (void)distributeObjects:(NSArray *)objects;
- (void)workingComplete;

@end

@interface TBLoopDistributer ()

// 留给work使用的，用于添加代理
@property (nonatomic, weak) id <TBLoopDistributerDelegate> delegate;

@end

