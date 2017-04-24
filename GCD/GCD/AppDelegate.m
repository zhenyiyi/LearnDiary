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
    
    
<<<<<<< HEAD
//    YYDispatchQueuePool *pool = [[YYDispatchQueuePool alloc] initWithName:@"dispatch.fenglin" queueCount:5 qos:NSQualityOfServiceUserInteractive];
//    
//    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.fenglin.concurrent", DISPATCH_QUEUE_CONCURRENT);
//    
//    for (NSUInteger i=0; i<10000; i++) {
//        dispatch_queue_t queue = [pool queue];
//        dispatch_async(queue, ^{
//            NSLog(@"i-> %lu currentThread-> %@",(unsigned long)i,[NSThread currentThread]);
//            sleep(10);
=======
//    FLDispatchQueuePool *pool = [[FLDispatchQueuePool alloc] initWithName:@"dispatch.fenglin" queueCount:5 qos:NSQualityOfServiceUserInteractive];
//    
//    
//    
//    for (NSUInteger i=0; i<100; i++) {
//        dispatch_queue_t queue = [pool queue];
//        dispatch_async(queue, ^{
//            NSLog(@"i-> %lu currentThread-> %@",(unsigned long)i,[NSThread currentThread]);
//            sleep(1);
>>>>>>> 8eb865027be862dd21f1f04542ae0d1b202ab85a
//            NSLog(@"-------------------------");
//        });
//    }
    
    return YES;
}
@end
