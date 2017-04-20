//
//  ViewController.m
//  TestCrash
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
    
    [self crash2];
}


- (void)crash2{
    CGFloat b = 0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 100, 200/b)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
}

- (void)crash1{
    
    id num = @(1);
    
    NSLog(@"%p",num);
//    NSLog(@" %@",[num objectForKey:@"111"]);
    NSLog(@" %@",num[@"2222"]);
    /*
     * 
     *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[__NSCFNumber objectForKeyedSubscript:]: unrecognized selector sent to instance 0xb000000000000012'
     */
}

@end
