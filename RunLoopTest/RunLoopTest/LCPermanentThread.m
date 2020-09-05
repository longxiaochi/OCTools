//
//  LCPermanentThread.m
//  RunLoopTest
//
//  Created by LongMac on 2020/9/4.
//  Copyright © 2020 LongMac. All rights reserved.
//

#import "LCPermanentThread.h"

@interface LCThread : NSThread
@end

@implementation LCThread

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end

@interface LCPermanentThread()

@property (nonatomic, strong) LCThread *innerThread;
@property (nonatomic, assign, getter=isStopped) BOOL stopped;

@end

@implementation LCPermanentThread

- (instancetype)init {
    if (self = [super init]) {
        
        __weak typeof(self) weakSelf = self;
        self.innerThread = [[LCThread alloc] initWithBlock:^{
            self.stopped = NO;
            // 加入Source1，保证RunLoop不会立即退出
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
            while (weakSelf && !weakSelf.isStopped) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
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
    
    self.stopped = YES;
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
