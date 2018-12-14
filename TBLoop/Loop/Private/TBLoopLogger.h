//
//  TBLoopLogger.h
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __TBLoopLogger(fmt, ...)                                \
            [TBLoopLogger  function:__PRETTY_FUNCTION__         \
                               line:__LINE__                    \
                                log:[NSString stringWithFormat:fmt, ##__VA_ARGS__]];


@interface TBLoopLogger : NSObject

+ (void)function:(const char *)func
            line:(NSInteger)line
             log:(NSString *)log, ... ;

/**
 是否需要调试日志输出
 
 @param enable 默认为yes
 */
+ (void)debugLogEnable:(BOOL)enable;

@end
