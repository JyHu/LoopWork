//
//  TBLoopLogger.m
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import "TBLoopLogger.h"
#include <os/log.h>
#import "TBLoop.h"

static BOOL debugLogEnable_ = YES;

@implementation TBLoopLogger

+ (void)function:(const char *)func line:(NSInteger)line log:(NSString *)log, ... {
    if (debugLogEnable_) {    
        va_list args;
        va_start(args, log);
        // 如果有%会导致format crash
        // https://github.com/CocoaLumberjack/CocoaLumberjack/issues/735
        NSString *logFmt = [log stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
        os_log(os_log_create("Loop", "Default"), "%s [%ld] %s", func, line, [[[NSString alloc] initWithFormat:logFmt arguments:args] UTF8String]);
        
        va_end(args);
    }
}

/**
 是否需要调试日志输出
 
 @param enable 默认为yes
 */
+ (void)debugLogEnable:(BOOL)enable {
    debugLogEnable_ = YES;
}

@end
