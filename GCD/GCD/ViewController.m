//
//  ViewController.m
//  GCD
//
//  Created by fenglin on 2017/4/19.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"


@interface ViewController (){
    void *strogeQueueTag;
    dispatch_queue_t strogeQueue;
   
    Person *p1;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    strogeQueueTag = &strogeQueueTag;
    strogeQueue = dispatch_queue_create("com.fenglin.serial", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_set_specific(strogeQueue, strogeQueueTag, strogeQueueTag, NULL);
    
    p1 = [Person new];
    
//    [self syncMethod];
    
//    [self ayncMethod];
    
//    [self targetQueue1];
    
//    [self targetQueue2];
    
<<<<<<< HEAD
    [self dispatchBarrier];
}

-(void)dispatchBarrier{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.fenglin.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_async(concurrentQueue, ^{
        NSLog(@"222222");
        [NSThread sleepForTimeInterval:3];
    });
    
    dispatch_barrier_async(concurrentQueue, ^{
        NSLog(@"111111");
    });
=======
//    [self barrier];
    
//    [self asyncBlock];
    
//    [self executeBlock];
    
    [self dellocOnSomeQueue];
}


/**
  在某个队列中释放对象。
 */
- (void)dellocOnSomeQueue{
    Person *p = p1;
    p1 = nil;
    dispatch_async(strogeQueue, ^{
        [p hash];
        NSLog(@"%s currentThread-> %@",__func__,[NSThread currentThread]);
    });
}

- (void) testSync{
    
    NSLog(@"BBBBBB");
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"currentThread-> %@ <-",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        NSLog(@"out");
    });
    
    /*
     void dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
     
     Submits a block object for execution on a dispatch queue and waits until that block completes.
     
     Submits a block to a dispatch queue for synchronous execution.
     Unlike dispatch_async, this function does not return until the block has finished.
     Calling this function and targeting the current queue results in deadlock.
     
     Unlike with dispatch_async, no retain is performed on the target queue.
     Because calls to this function are synchronous, it "borrows" the reference of the caller. "borrows->借用"
     Moreover, no Block_copy is performed on the block.
     As an optimization, this function invokes the block on the current thread when possible.
     
     */
    
    /*
     dispatch_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
     Submits a block for asynchronous execution on a dispatch queue and returns immediately.
     
     This function is the fundamental mechanism for submitting blocks to a dispatch queue. Calls to this function always return immediately after the block has been submitted and never wait for the block to be invoked.
     The target queue determines whether the block is invoked serially or concurrently with respect to other blocks submitted to that same queue.
     Independent serial queues are processed concurrently with respect to each other.
     */
    
}

- (void)executeBlock{
    for (NSUInteger i=0; i<1000; i++) {
        [self executeBlock:^{
            NSLog(@"%lu currentThread-> %@",(unsigned long)i ,[NSThread currentThread]);
        }];
    }
    
    [self executeBlock:^{
        NSLog(@"%d currentThread-> %@",11 ,[NSThread currentThread]);
    }];
//    2017-04-21 09:13:46.774 
//    2017-04-21 09:13:47.716
}


- (void)asyncBlock{
    for (NSUInteger i=0; i<1000; i++) {
        [self scheduleBlock:^{
            NSLog(@"%lu currentThread-> %@",(unsigned long)i ,[NSThread currentThread]);
        }];
    }
    
    [self scheduleBlock:^{
        NSLog(@"%d currentThread-> %@",11 ,[NSThread currentThread]);
    }];
}

- (void)executeBlock:(dispatch_block_t)block{
    if ( dispatch_get_specific(strogeQueueTag)) {
        if (block) block();
    }else{
        dispatch_sync(strogeQueue, ^{
            if (block) block();
        });
    }
}
- (void)scheduleBlock:(dispatch_block_t)block{
    if ( dispatch_get_specific(strogeQueueTag)) {
        if (block) block();
    }else{
        dispatch_async(strogeQueue, ^{
           if (block) block();
        });
    }
    
//    2017-04-21 09:10:47.141
//    2017-04-21 09:10:48.298
    
}

- (void)barrier{
    dispatch_queue_t queue = dispatch_queue_create("com.fenglin.concurrent", DISPATCH_QUEUE_CONCURRENT);
    for (NSUInteger i=0; i<1000; i++) {
        dispatch_barrier_async(queue, ^{
            NSLog(@"%lu currentThread-> %@",(unsigned long)i ,[NSThread currentThread]);
        });
    }
    dispatch_barrier_async(queue, ^{
        NSLog(@"00000000000 %@ ",[NSThread currentThread]);
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"111111111  %@ ",[NSThread currentThread]);
    });
    
//    2017-04-21 09:11:42.979
//    2017-04-21 09:11:44.127
>>>>>>> 8eb865027be862dd21f1f04542ae0d1b202ab85a
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
