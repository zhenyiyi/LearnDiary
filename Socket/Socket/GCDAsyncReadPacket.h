//
//  GCDAsyncReadPacket.h
//  Socket
//
//  Created by fenglin on 2018/12/13.
//  Copyright © 2018年 quanshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocketPreBuffer.h"

/**
 * GCDAsyncReadPacket包含任何给定读取的指令。
 * 读取包的内容允许代码确定我们是否:
 * - 阅读到一定长度
 * - 读取到某个分隔符
 * - 或只是读取可用数据的第一个块
 * The GCDAsyncReadPacket encompasses the instructions for any given read.
 * The content of a read packet allows the code to determine if we're:
 *  - reading to a certain length
 *  - reading to a certain separator
 *  - or simply reading the first chunk of available data
 **/
@interface GCDAsyncReadPacket : NSObject
{
@public
    NSMutableData *buffer;
    NSUInteger startOffset;
    NSUInteger bytesDone;
    NSUInteger maxLength;
    NSTimeInterval timeout;
    NSUInteger readLength;
    NSData *term;
    BOOL bufferOwner;
    NSUInteger originalBufferLength;
    long tag;
}
// terminator 终结者
- (id)initWithData:(NSMutableData *)d
       startOffset:(NSUInteger)s
         maxLength:(NSUInteger)m
           timeout:(NSTimeInterval)t
        readLength:(NSUInteger)l
        terminator:(NSData *)e
               tag:(long)i;

- (void)ensureCapacityForAdditionalDataOfLength:(NSUInteger)bytesToRead;

- (NSUInteger)optimalReadLengthWithDefault:(NSUInteger)defaultValue shouldPreBuffer:(BOOL *)shouldPreBufferPtr;

- (NSUInteger)readLengthForNonTermWithHint:(NSUInteger)bytesAvailable;
- (NSUInteger)readLengthForTermWithHint:(NSUInteger)bytesAvailable shouldPreBuffer:(BOOL *)shouldPreBufferPtr;
- (NSUInteger)readLengthForTermWithPreBuffer:(GCDAsyncSocketPreBuffer *)preBuffer found:(BOOL *)foundPtr;

- (NSInteger)searchForTermAfterPreBuffering:(ssize_t)numBytes;

@end
