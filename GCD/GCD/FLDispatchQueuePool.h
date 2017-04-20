//
//  FLDispatchQueuePool.h
//  GCD
//
//  Created by fenglin on 2017/4/20.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLDispatchQueuePool : NSObject
@property(nonatomic,copy,readonly) NSString *name;

- (instancetype)initWithName:(nullable NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;

- (dispatch_queue_t)queue;

@end
