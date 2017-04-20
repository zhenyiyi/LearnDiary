//
//  ViewController.m
//  GCD
//
//  Created by fenglin on 2017/4/19.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self syncMethod];
    
//    [self ayncMethod];
    
//    [self targetQueue1];
    
//    [self targetQueue2];
}




- (void)priority{
    dispatch_queue_attr_t  attr = dispatch_queue_attr_make_with_qos_class(NULL, QOS_CLASS_USER_INTERACTIVE, 0);
    
    dispatch_queue_t queue = dispatch_queue_create("com.fenglin", attr);
    
    
}
/**
 第一种情况:使用dispatch_set_target_queue(Dispatch Queue1, Dispatch Queue2)实现队列的动态调度管理
  dispatch队列不支持cancel（取消），没有实现dispatch_cancel()函数，不像NSOperationQueue，不得不说这是个小小的缺憾
  可以自己设置bool来实现dispatch cancel。
 */
- (void)targetQueue2{
    
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t targetQueue = dispatch_queue_create("targetQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_set_target_queue(queue1, targetQueue);
    
    dispatch_async(queue1, ^{
        for (NSInteger i=0; i<10; i++) {
            NSLog(@"%s in %@",dispatch_queue_get_label(queue1),[NSThread currentThread]);
            
            [NSThread sleepForTimeInterval:1];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_suspend(queue1);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_suspend(targetQueue);
    });
    
    dispatch_async(queue1, ^{
        for (NSInteger i=0; i<10; i++) {
            NSLog(@"%s in %@ num-> %ld",dispatch_queue_get_label(queue1),[NSThread currentThread],i);
        }
    });
    
    dispatch_async(targetQueue, ^{
        for (NSInteger i=0; i<10; i++) {
            NSLog(@"%s in %@ num-> %ld",dispatch_queue_get_label(targetQueue),[NSThread currentThread],i);
        }
    });
}


/**
 使用dispatch_set_target_queue将多个串行的queue指定到了同一目标，那么着多个串行queue在目标queue上就是同步执行的，不再是并行执行。
 */
- (void)targetQueue1{
    dispatch_queue_t targetQueue = dispatch_queue_create("targetQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t queue3 = dispatch_queue_create("queue3", DISPATCH_QUEUE_SERIAL);
    
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    dispatch_set_target_queue(queue3, targetQueue);
    
    NSLog(@"11111111111");
    dispatch_async(queue1, ^{
        NSLog(@"%s in %@",dispatch_queue_get_label(queue1),[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        NSLog(@"%s out ",dispatch_queue_get_label(queue1));
    });
    
    
    dispatch_async(queue2, ^{
        NSLog(@"%s in ",dispatch_queue_get_label(queue2));
        [NSThread sleepForTimeInterval:1];
        NSLog(@"%s out ",dispatch_queue_get_label(queue2));
    });
    
    dispatch_async(queue3, ^{
        NSLog(@"%s in ",dispatch_queue_get_label(queue3));
        [NSThread sleepForTimeInterval:1];
        NSLog(@"%s out ",dispatch_queue_get_label(queue3));
    });
    
    NSLog(@"2222222222");
}









- (void)syncMethod{
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"11111111");
    });
    NSLog(@"222222");
}

- (void)ayncMethod{
    dispatch_async(dispatch_get_global_queue(-2, 0), ^{
        NSLog(@"11111111");
    });
    NSLog(@"222222");
}

- (void)test{
    dispatch_queue_t serilQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serilQueue, ^{
        
    });
    dispatch_async(serilQueue, ^{
        
    });
}









@end
