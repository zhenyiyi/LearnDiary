//
//  AppDelegate.m
//  GCD
//
//  Created by fenglin on 2017/4/19.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "AppDelegate.h"
#import "YYDispatchQueuePool.h"
#import "FLDispatchQueuePool.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
//    YYDispatchQueuePool *pool = [[YYDispatchQueuePool alloc] initWithName:@"dispatch.fenglin" queueCount:5 qos:NSQualityOfServiceUserInteractive];
//    
//    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.fenglin.concurrent", DISPATCH_QUEUE_CONCURRENT);
//    
//    for (NSUInteger i=0; i<10000; i++) {
//        dispatch_queue_t queue = [pool queue];
//        dispatch_async(queue, ^{
//            NSLog(@"i-> %lu currentThread-> %@",(unsigned long)i,[NSThread currentThread]);
//            sleep(10);
//            NSLog(@"-------------------------");
//        });
//    }
    
    return YES;
}
@end
