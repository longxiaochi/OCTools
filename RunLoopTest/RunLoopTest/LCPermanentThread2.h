//
//  LCPermanentThread2.h
//  RunLoopTest
//
//  Created by LongMac on 2020/9/4.
//  Copyright © 2020 LongMac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LCPermanentTask) (void);

@interface LCPermanentThread2 : NSObject

/**
 启动线程
 */
- (void)run;

/**
  执行任务
*/
- (void)excuteTask:(LCPermanentTask)task;


/**
 停止线程
 */
- (void)stop;
@end


NS_ASSUME_NONNULL_END
