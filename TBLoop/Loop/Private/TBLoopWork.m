//
//  TBLoopWork.m
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import "TBLoopWork.h"
#import "TBLoopDistributer+TBPrivate.h"
#import "TBLoopNilObject.h"
#import "TBLoopLogger.h"

@interface TBLoopWork() <TBLoopDistributerDelegate>

// 任务的分发者
@property (nonatomic, strong) TBLoopDistributer *distributer;

// 依赖和回调
@property (nonatomic, strong, readwrite) NSMutableArray <TBLoopWorkUnit *> *units;

// 轮询的任务
@property (nonatomic, copy, readwrite) TBLoopWorkBlock work;

// 轮询频率
@property (nonatomic, assign, readwrite) NSTimeInterval interval;

// 是否在执行
@property (nonatomic, assign, readwrite) BOOL executing;

// 任务的唯一标识
@property (nonatomic, copy, readwrite) NSString *identifier;

@end

@implementation TBLoopWork

+ (instancetype)work:(TBLoopWorkBlock)work interval:(NSTimeInterval)interval identifier:(NSString *)identifier {
    NSAssert(work != nil, @"Loop work can not be nil.");
    NSAssert(interval > 0, @"Loop frequency must greater than 0.");
    TBLoopWork *loopWork = [[TBLoopWork alloc] init];
    loopWork.work = [work copy];
    loopWork.interval = interval;
    loopWork.identifier = identifier;
    return loopWork;
}

- (BOOL)working {
    if (self.units.count == 0) {
        return NO;
    }
    
    NSMutableArray <TBLoopWorkUnit *> *invalidatedUnits = [[NSMutableArray alloc] init];
    
    for (TBLoopWorkUnit *unit in self.units) {
        if (unit.isInvalid) {
            [invalidatedUnits addObject:unit];
            
            __TBLoopLogger(@"[unit : %@] in [work : %@] [timer : %f] invalid and removed.", unit.unitIdentifier, self.identifier, self.interval);
        }
    }
    
    [self.units removeObjectsInArray:invalidatedUnits];
    
    if (self.units.count == 0) {
        return NO;
    }
    
    self.work(self.distributer);
    self.executing = YES;
    
    return YES;
}

- (void)distributeObjects:(NSArray *)objects {
    
    __TBLoopLogger(@"Distributer in [work : %@] distribute objects : %@", self.identifier, objects);
    
    for (TBLoopWorkUnit *unit in self.units) {
        if (unit.isInvalid) {
            continue;
        }
        
        if (objects == nil || objects.count == 0) {
            unit.callback();
        } else if (objects.count == 1) {
            unit.callback([self originalObject:objects[0]]);
        } else if (objects.count == 2) {
            unit.callback([self originalObject:objects[0]],
                          [self originalObject:objects[1]]);
        } else if (objects.count == 3) {
            unit.callback([self originalObject:objects[0]],
                          [self originalObject:objects[1]],
                          [self originalObject:objects[2]]);
        } else if (objects.count == 4) {
            unit.callback([self originalObject:objects[0]],
                          [self originalObject:objects[1]],
                          [self originalObject:objects[2]],
                          [self originalObject:objects[3]]);
        } else if (objects.count == 4) {
            unit.callback([self originalObject:objects[0]],
                          [self originalObject:objects[1]],
                          [self originalObject:objects[2]],
                          [self originalObject:objects[3]],
                          [self originalObject:objects[4]]);
        } else if (objects.count == 5) {
            unit.callback([self originalObject:objects[0]],
                          [self originalObject:objects[1]],
                          [self originalObject:objects[2]],
                          [self originalObject:objects[3]],
                          [self originalObject:objects[4]],
                          [self originalObject:objects[5]]);
        } else if (objects.count == 6) {
            unit.callback([self originalObject:objects[0]],
                          [self originalObject:objects[1]],
                          [self originalObject:objects[2]],
                          [self originalObject:objects[3]],
                          [self originalObject:objects[4]],
                          [self originalObject:objects[5]],
                          [self originalObject:objects[6]]);
        } else {
            unit.callback([self originalObject:objects[0]],
                          [self originalObject:objects[1]],
                          [self originalObject:objects[2]],
                          [self originalObject:objects[3]],
                          [self originalObject:objects[4]],
                          [self originalObject:objects[5]],
                          [self originalObject:objects[6]],
                          [self originalObject:objects[7]]);
        }
    }
}

- (void)workingComplete {
    self.executing = NO;
    
    __TBLoopLogger(@"[work : %@] in [timer : %f] working complete.", self.identifier, self.interval);
}

#pragma mark - help methods

- (id)originalObject:(id)object {
    return [object isKindOfClass:[TBLoopNilObject class]] ? nil : object;
}

#pragma mark - getter

- (NSMutableArray<TBLoopWorkUnit *> *)units {
    if (!_units) {
        _units = [[NSMutableArray alloc] init];
    }
    return _units;
}

- (TBLoopDistributer *)distributer {
    if (!_distributer) {
        _distributer = [[TBLoopDistributer alloc] init];
        _distributer.delegate = self;
    }
    return _distributer;
}

@end
