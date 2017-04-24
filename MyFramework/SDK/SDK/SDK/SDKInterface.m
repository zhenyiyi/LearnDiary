//
//  SDKInterface.m
//  SDK
//
//  Created by fenglin on 2017/4/24.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "SDKInterface.h"
#import "Test.h"

@implementation SDKInterface
+ (void)interface{
    [Test test];
}
+ (NSString *)version{
    return @"1.0.0";
}
@end
