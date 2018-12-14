//
//  TBLoopWorkUnit.m
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import "TBLoopWorkUnit.h"

@interface TBLoopWorkUnit()

@property (nonatomic, copy, readwrite) NSString *unitIdentifier;
@property (nonatomic, weak, readwrite) id dependence;
@property (nonatomic, copy, readwrite) TBLoopCallbackBlock callback;

@end

@implementation TBLoopWorkUnit

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

+ (instancetype)unitWithCallback:(TBLoopCallbackBlock)callback {
    NSAssert(callback != nil, @"callback can not be nil");
    return [self unitWithCallback:callback dependence:nil manualControl:YES];
}

+ (instancetype)unitWithCallback:(TBLoopCallbackBlock)callback dependence:(id)dependence {
    NSAssert(callback != nil, @"callback can not be nil");
    return [self unitWithCallback:callback dependence:dependence manualControl:!!dependence];
}

+ (instancetype)unitWithCallback:(TBLoopCallbackBlock)callback dependence:(id)dependence manualControl:(BOOL)manualControl {
    TBLoopWorkUnit *unit = [[TBLoopWorkUnit alloc] init];
    unit.callback = [callback copy];
    unit.dependence = dependence;
    unit.manualControl = manualControl;
    return unit;
}

#pragma clang diagnostic pop

- (BOOL)isInvalid {
    // 如果callback为空，肯定无效
    if (self.callback == nil) {
        return YES;
    }
    
    // 如果是手动管理的，则不需要依赖，肯定有效
    if (self.manualControl) {
        return NO;
    }
    
    return !self.dependence;
}

- (NSString *)unitIdentifier {
    if (!_unitIdentifier) {
        CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
        CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
        CFRelease(uuid_ref);
        
        _unitIdentifier = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
        
        CFRelease(uuid_string_ref);
    }
    return _unitIdentifier;
}

@end
