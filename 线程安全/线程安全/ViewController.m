//
//  ViewController.m
//  线程安全
//
//  Created by fenglin on 2017/4/24.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    dispatch_queue_t sellQueue2;
    void *sellQueue2Tag;
}
@property(nonatomic,assign)NSUInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.count = 10;
    sellQueue2 = dispatch_queue_create("com.fenglin.sellQueue2", NULL);
    sellQueue2Tag = &sellQueue2Tag;
    dispatch_queue_set_specific(sellQueue2, sellQueue2Tag, sellQueue2Tag, NULL);
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sellTickets) userInfo:nil repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sellTickets) userInfo:nil repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sellTickets) userInfo:nil repeats:YES];
}

- (void)sellTickets{
    
    dispatch_block_t block = ^{
        if (self.count == 0) {
            return ;
        }
        self.count --;
        NSLog(@"currentThread-> %@ count -> %ld",[NSThread currentThread],_count);
    };
    
    if (dispatch_get_specific(sellQueue2Tag)) {
        block();
    }else{
        dispatch_async(sellQueue2, ^{
            block();
        });
    }
}


@end
