//
//  TBLoopDistributer.h
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBLoopDistributer : NSObject

/*
 由任务执行的地方向外分发数据
 */

- (void)distribute;
- (void)distributeObj:(id)obj;
- (void)distributeObj:(id)obj obj1:(id)obj1;
- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2;
- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 obj3:(id)obj3;
- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 obj3:(id)obj3 obj4:(id)obj4;
- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 obj3:(id)obj3 obj4:(id)obj4 obj5:(id)obj5;
- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 obj3:(id)obj3 obj4:(id)obj4 obj5:(id)obj5 others:(NSArray *)others;

/*
 告知任务执行结束
 */
- (void)workingComplete;

@end
