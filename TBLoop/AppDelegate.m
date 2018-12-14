//
//  AppDelegate.m
//  TBLoop
//
//  Created by 胡金友 on 2018/12/7.
//  Copyright © 2018 老虎证券. All rights reserved.
//

#import "AppDelegate.h"
#import "TBLoop.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSMutableArray *dependences;

@property (nonatomic, assign) NSTimeInterval interval;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.interval = 2;
}

// 添加一个没有保存的依赖的任务，测试任务轮询不会安全进行下去
- (IBAction)addRequestWithTempDependence:(NSButton *)sender {
    NSString *identifier = [NSString stringWithFormat:@"key_%.2f", self.interval];
    
    [[TBLoop defaultLoop] loopWork:^(TBLoopDistributer *distributer) {
        [distributer distributeObj:nil];
    } interval:self.interval dependence:[NSObject new] identifier:identifier response:^(id obj1, id obj2, id obj3, id obj4){
        NSLog(@"%@ - %@ - %@ - %@", obj1, obj2, obj3, obj4);
    }];
    
    self.interval += 0.2;
}

// 添加有缓存的依赖任务，测试轮询任务会安全进行
- (IBAction)addRequestWithAssociatedDependence:(NSButton *)sender {
    NSObject *dep = [[NSObject alloc] init];
    [self.dependences addObject:dep];
    
    NSString *identifier = [NSString stringWithFormat:@"key_%.2f", self.interval];
    
    NSString *key = [[TBLoop defaultLoop] loopWork:^(TBLoopDistributer *distributer) {
//        [distributer distribute:@"1", @"2", @"3", @"4"];
        [distributer distributeObj:@1 obj1:@2 obj2:@3 obj3:@4];
    } interval:self.interval dependence:dep identifier:identifier response:^(id obj1, id obj2, id obj3, id obj4){
        NSLog(@"%@ - %@ - %@ - %@", obj1, obj2, obj3, obj4);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[TBLoop defaultLoop] removeCallbackWithUnitID:key];
    });
    
    self.interval += 0.2;
}

// 移除一个依赖，测试依赖移除以后任务会停止
- (IBAction)removeDependence:(id)sender {
    // 随便移除一个任务，在轮询的时候就不会对他进行callback了，如果任务为空了，那么轮询的timer也会移除
    if (self.dependences.count > 0) {
        [self.dependences removeObjectAtIndex:(NSUInteger)arc4random_uniform((uint32_t)self.dependences.count)];
    }
}

- (IBAction)removeInterval:(id)sender {
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSMutableArray *)dependences {
    if (!_dependences) {
        _dependences = [[NSMutableArray alloc] init];
    }
    return _dependences;
}

@end
