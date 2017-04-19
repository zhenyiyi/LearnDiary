//
//  ViewController.m
//  UIBezierPath
//
//  Created by fenglin on 2017/4/18.
//  Copyright © 2017年 yhy. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()<CAAnimationDelegate>{
    UIView *contentView;
    UIImageView *imgView;
    UIView *ball;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 300, 300)];
    contentView.backgroundColor = [UIColor cyanColor];
    contentView.layer.cornerRadius = 150;
    contentView.layer.masksToBounds = YES;
    contentView.layer.borderWidth = 5;
    contentView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.view addSubview:contentView];
    
    imgView = [[UIImageView alloc] initWithFrame:contentView.bounds];
    [contentView addSubview:imgView];
    imgView.backgroundColor = [UIColor redColor];
    [contentView bringSubviewToFront:imgView];
    
    ball = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    ball.backgroundColor = [UIColor blackColor];
//    ball.center = imgView.center;
    ball.layer.cornerRadius = 5;
    ball.layer.masksToBounds = YES;
    [contentView addSubview:ball];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:imgView.center radius:150-10 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.removedOnCompletion = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 2;
    animation.duration = 3;
    animation.delegate = self;
    
    [ball.layer addAnimation:animation forKey:@"roration"];
    
}


- (void)animationDidStart:(CAAnimation *)anim{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
}



@end
