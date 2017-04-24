//
//  ViewController.m
//  AFNetworking详解
//
//  Created by fenglin on 2017/4/21.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.2" options:NSNumericSearch] == NSOrderedAscending) {
        // 低于8.2的版本可以这么用。
    }else{
        // 高于8.2的版本
    }
    
    
    for (NSUInteger i=0; i<100; i++) {
//        Create and returns a new UUID with RFC 4122 version 4 random bytes.
        NSLog(@"UUID-> %@",[NSUUID UUID]);
    }
    
    
    
}




@end
