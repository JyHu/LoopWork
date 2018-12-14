//
//  TBLoopTimer.m
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import "TBLoopTimer.h"

static dispatch_queue_t loop_timer_queue;

@interface TBLoopTimer()

@property (nonatomic, strong, readwrite) GCDTimer *timer;
@property (nonatomic, assign, readwrite) NSTimeInterval interval;
@property (nonatomic, strong, readwrite) NSMutableDictionary <NSString *, TBLoopWork *> *works;

@end

@implementation TBLoopTimer

+ (void)load {
    loop_timer_queue = dispatch_queue_create("loop_timer_queue_identifier", DISPATCH_QUEUE_CONCURRENT);
}

+ (TBLoopTimer *)timerWithInterval:(NSTimeInterval)interval block:(void (^)(void))block {
    TBLoopTimer *timer = [[TBLoopTimer alloc] init];
    timer.interval = interval;
    timer.timer = [GCDTimer scheduledTimerWithTimeInterval:interval repeats:YES queue:loop_timer_queue block:block];
    return timer;
}

- (NSMutableDictionary<NSString *,TBLoopWork *> *)works {
    if (!_works) {
        _works = [[NSMutableDictionary alloc] init];
    }
    return _works;
}

- (void)invalidate {
    [self.timer invalidate];
    self.timer = nil;
}

@end
