//
//  Message.m
//  wcdbTest
//
//  Created by fenglin on 2018/12/4.
//  Copyright © 2018年 quanshi. All rights reserved.
//

#import "Message.h"
#import <WCDB/WCDB.h>

/*
 在WCDB内，ORM（Object Relational Mapping）是指
 
 将一个ObjC的类，映射到数据库的表和索引；
 将类的property，映射到数据库表的字段；
 */
@implementation Message
WCDB_IMPLEMENTATION(Message)
WCDB_SYNTHESIZE(Message, localID)
WCDB_SYNTHESIZE(Message, content)
WCDB_SYNTHESIZE(Message, createTime)
WCDB_SYNTHESIZE(Message, modifiedTime)

WCDB_PRIMARY(Message, localID)
WCDB_INDEX(Message, "_index", createTime)

@end
