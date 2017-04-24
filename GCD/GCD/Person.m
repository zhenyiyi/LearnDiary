//
//  Person.m
//  GCD
//
//  Created by fenglin on 2017/4/21.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "Person.h"

@implementation Person


- (void)dealloc{
    NSLog(@"%s currentThread-> %@",__func__,[NSThread currentThread]);
}
@end
