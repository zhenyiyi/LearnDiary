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
    
    [self ayncMethod];
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
