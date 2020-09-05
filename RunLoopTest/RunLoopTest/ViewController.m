//
//  ViewController.m
//  RunLoopTest
//
//  Created by LongMac on 2020/9/4.
//  Copyright © 2020 LongMac. All rights reserved.
//

#import "ViewController.h"
#import "LCPermanentThread2.h"

@interface ViewController ()

@property (nonatomic, strong) LCPermanentThread2 *thread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.thread = [[LCPermanentThread2 alloc] init];
    [self.thread run];
}

- (IBAction)stop:(id)sender {
    [self.thread stop];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.thread excuteTask:^{
        NSLog(@"-------- excute task on thead: %@", [NSThread currentThread]);
    }];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
