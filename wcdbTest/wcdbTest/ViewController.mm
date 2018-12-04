//
//  ViewController.m
//  wcdbTest
//
//  Created by fenglin on 2018/12/4.
//  Copyright © 2018年 quanshi. All rights reserved.
//

#import "ViewController.h"
#import "Message.h"
#import <WCDB/WCDB.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"my.database"];
    WCTDatabase *database = [[WCTDatabase alloc] initWithPath:path];
    BOOL res = [database createTableAndIndexesOfName:@"message" withClass:Message.class];
    NSLog(@"res-> %d",res);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
