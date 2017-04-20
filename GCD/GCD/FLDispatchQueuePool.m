//
//  FLDispatchQueuePool.m
//  GCD
//
//  Created by fenglin on 2017/4/20.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "FLDispatchQueuePool.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

typedef struct{
    const char *name;
    int32_t counter;
    int32_t queueCount;
    void **queues;
    
}FLDispatchContext;

static long getDispatchIdentifier(NSQualityOfService qos){
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUserInitiated: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUtility: return DISPATCH_QUEUE_PRIORITY_LOW;
        case NSQualityOfServiceBackground: return DISPATCH_QUEUE_PRIORITY_LOW;
        case NSQualityOfServiceDefault :
        default:
            return DISPATCH_QUEUE_PRIORITY_DEFAULT;
    }
}

static FLDispatchContext* createDispatchContext(const char *name, NSUInteger queueCount, NSQualityOfService qos){
    FLDispatchContext *context = calloc(1, sizeof(FLDispatchContext));
    context->queues =  calloc(queueCount, sizeof(void *));
    long identifier = getDispatchIdentifier(qos);
    for (NSUInteger i=0; i<queueCount; i++) {
        dispatch_queue_t queue = dispatch_queue_create("com.fenglin.dispatch", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(identifier, 0));
        context->queues[i] = (__bridge_retained void *)(queue);
    }
    if (name) {
        context->name = strdup(name);
    }
    context->queueCount = (int32_t)queueCount;
    
    return context;
}

static void dispatch_realeaseContext(FLDispatchContext *context){
    for (NSUInteger i=0; i<context->queueCount; i++) {
        void *queuePointer = context->queues[i];
        dispatch_queue_t queue = (__bridge dispatch_queue_t)(queuePointer);
        queue = nil;
    }
    if (context->name) {
        free((void *)context->name);
    }
}

static dispatch_queue_t dispatch_get_queue(FLDispatchContext *context){
    int32_t value =  OSAtomicAdd32(1, &context->counter);
    return (__bridge dispatch_queue_t)(context->queues[value%context->queueCount]);
}

@interface FLDispatchQueuePool (){
    FLDispatchContext *_dispatchContext;
}

@end

@implementation FLDispatchQueuePool

- (void)dealloc{
    if (_dispatchContext) {
       dispatch_realeaseContext(_dispatchContext);
        _dispatchContext = NULL;
    }
}
- (instancetype)initWithName:(NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos{
    if (queueCount>32) {
        return nil;
    }
    self = [super init];
    _dispatchContext = createDispatchContext([name UTF8String],queueCount,qos);
    if (_dispatchContext == NULL) {
        return nil;
    }
    _name = name;
    
    return self;
}

- (dispatch_queue_t)queue{
    return dispatch_get_queue(_dispatchContext);
}
@end
