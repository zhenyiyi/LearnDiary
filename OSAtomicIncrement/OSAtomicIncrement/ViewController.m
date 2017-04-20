//
//  ViewController.m
//  OSAtomicIncrement
//
//  Created by fenglin on 2017/4/20.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "ViewController.h"
#import <libkern/OSAtomic.h>


@interface ViewController ()
{
    int32_t pendingRequests;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    pendingRequests = 0;
    
    int32_t value =  OSAtomicIncrement32(&pendingRequests);
    
    NSLog(@"-> %d",value);
    
    value = OSAtomicDecrement32(&pendingRequests);
    
    NSLog(@"-> %d",value);
    
}


@end
