//
//  main.m
//  Socket
//
//  Created by fenglin on 2018/12/13.
//  Copyright © 2018年 quanshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocketPreBuffer.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        GCDAsyncSocketPreBuffer * preBuffer = [[GCDAsyncSocketPreBuffer alloc] initWithCapacity:(1024 * 4)];
        
        NSLog(@"[preBuffer availableBytes]-> %zd",[preBuffer availableBytes]);
        
        NSLog(@"[preBuffer availableSpace]-> %zd",[preBuffer availableSpace]);
        
        uint8_t *readBufferLength;
        size_t availableBytesLength;
        [preBuffer getReadBuffer:&readBufferLength availableBytes:&availableBytesLength];
        NSLog(@"readBufferLength-> %s availableBytesLength-> %zd",readBufferLength, availableBytesLength);
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
