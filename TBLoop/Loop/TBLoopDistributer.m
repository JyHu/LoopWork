//
//  TBLoopDistributer.m
//  TBLoop
//
//  Created by 胡金友 on 2018/12/14.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import "TBLoopDistributer.h"
#import "TBLoopDistributer+TBPrivate.h"
#import <objc/runtime.h>
#import "TBLoopNilObject.h"

@implementation TBLoopDistributer

- (void)distribute {
    [self _distributeWithObjects:nil];
}

- (void)distributeObj:(id)obj {
    [self _distributeWithObjects:@[ [self _legalObject:obj] ]];
}

- (void)distributeObj:(id)obj obj1:(id)obj1 {
    [self _distributeWithObjects: @[ [self _legalObject:obj],
                                     [self _legalObject:obj1]]];
}

- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 {
    [self _distributeWithObjects: @[ [self _legalObject:obj],
                                     [self _legalObject:obj1],
                                     [self _legalObject:obj2]]];
}

- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 obj3:(id)obj3 {
    [self _distributeWithObjects: @[ [self _legalObject:obj],
                                     [self _legalObject:obj1],
                                     [self _legalObject:obj2],
                                     [self _legalObject:obj3]]];
}

- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 obj3:(id)obj3 obj4:(id)obj4 {
    [self _distributeWithObjects: @[ [self _legalObject:obj],
                                     [self _legalObject:obj1],
                                     [self _legalObject:obj2],
                                     [self _legalObject:obj3],
                                     [self _legalObject:obj4]]];
}

- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 obj3:(id)obj3 obj4:(id)obj4 obj5:(id)obj5 {
    [self _distributeWithObjects: @[ [self _legalObject:obj],
                                     [self _legalObject:obj1],
                                     [self _legalObject:obj2],
                                     [self _legalObject:obj3],
                                     [self _legalObject:obj4],
                                     [self _legalObject:obj5]]];
}

- (void)distributeObj:(id)obj obj1:(id)obj1 obj2:(id)obj2 obj3:(id)obj3 obj4:(id)obj4 obj5:(id)obj5 others:(NSArray *)others {
    [self _distributeWithObjects: @[ [self _legalObject:obj],
                                     [self _legalObject:obj1],
                                     [self _legalObject:obj2],
                                     [self _legalObject:obj3],
                                     [self _legalObject:obj4],
                                     [self _legalObject:obj5],
                                     [self _legalObject:others]]];
}

- (void)_distributeWithObjects:(NSArray *)objects {
    if (self.delegate) {
        [self.delegate distributeObjects:objects];
    }
}

- (id)_legalObject:(id)obj {
    return obj ?: [TBLoopNilObject object];
}

- (void)workingComplete {
    [self.delegate workingComplete];
}

@end
