//
//  LCPermanentThread2.m
//  RunLoopTest
//
//  Created by LongMac on 2020/9/4.
//  Copyright © 2020 LongMac. All rights reserved.
//

#import "LCPermanentThread2.h"

@interface LCPermanentThread2()

@property (nonatomic, strong) NSThread *innerThread;

@end

@implementation LCPermanentThread2

- (instancetype)init {
    if (self = [super init]) {
    
        self.innerThread = [[NSThread alloc] initWithBlock:^{
            
            // 创建source 添加到runloop中，保证runloop不会退出
            CFRunLoopSourceContext context = {0};
            CFRunLoopSourceRef source = CFRunLoopSourceCreate(CFAllocatorGetDefault(), 0, &context);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
            CFRelease(source);
            
            // 运行runloop
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
        }];
    }
    return self;
}

- (void)run {
    if (!self.innerThread) return;
    [self.innerThread start];
}

- (void)excuteTask:(LCPermanentTask)task {
    if (!self.innerThread || !task) return;
    
    [self performSelector:@selector(__excuteTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}

- (void)stop {
    if (!self.innerThread) return;
    
    // 在子线程中停止当前loop
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
    self.innerThread = nil;
}

#pragma mark - private method
- (void)__stop {
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)__excuteTask:(LCPermanentTask)task {
    task();
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self stop];
}
@end
