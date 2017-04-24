//
//  ____Tests.m
//  线程安全Tests
//
//  Created by fenglin on 2017/4/24.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ____Tests : XCTestCase{
    dispatch_queue_t sellQueue;
    dispatch_queue_t sellQueue2;
    void *sellQueue2Tag;
    NSLock *lock;
}
@property(nonatomic,assign)NSUInteger count;
@end

@implementation ____Tests

- (void)setUp {
    [super setUp];
    lock = [[NSLock alloc] init];
    self.count = 10;
    sellQueue = dispatch_queue_create("com.fenglin.sellQueue", DISPATCH_QUEUE_CONCURRENT);
    
    sellQueue2 = dispatch_queue_create("com.fenglin.sellQueue2", NULL);
    sellQueue2Tag = &sellQueue2Tag;
    dispatch_queue_set_specific(sellQueue2, sellQueue2Tag, sellQueue2Tag, NULL);
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

/*
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

- (void)testThreadSafe{
    [NSThread detachNewThreadSelector:@selector(sellTickets) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(sellTickets) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(sellTickets) toTarget:self withObject:nil];
    
    
}

- (void)sellTickets{
    [self methodFour];
}


- (void)methodOne{
    while (1) {
        @synchronized (self) {
            if (self.count == 0) {
                break;
            }
            NSLog(@"begin sell ticket");
            self.count --;
            NSLog(@"currentThread-> %@ count -> %ld",[NSThread currentThread],_count);
            
        }
    }
}

- (void)methodTwo{
    while (1) {
        dispatch_barrier_async(sellQueue, ^{
            if (self.count == 0) {
                return ;
            }
            NSLog(@"begin sell ticket");
            self.count --;
            NSLog(@"currentThread-> %@ count -> %ld",[NSThread currentThread],_count);
        });
    }
    
}

- (void)methodThree{
    while (1) {
        [lock lock];
        
        if (self.count == 0) {
            return ;
        }
        NSLog(@"begin sell ticket");
        self.count --;
        NSLog(@"currentThread-> %@ count -> %ld",[NSThread currentThread],_count);
        
        [lock unlock];
    }
}

- (void)methodFour{
    
    dispatch_block_t block = ^{
        if (self.count == 0) {
            return ;
        }
        NSLog(@"begin sell ticket");
        self.count --;
        NSLog(@"currentThread-> %@ count -> %ld",[NSThread currentThread],_count);
    };
    while (1) {
        
        if (dispatch_get_specific(sellQueue2Tag)) {
            block();
        }else{
            dispatch_async(sellQueue2, ^{
                block();
            });
        }
        
    }
}
@end
