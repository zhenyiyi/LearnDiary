//
//  GCDAsyncSocketPreBuffer.m
//  Socket
//
//  Created by fenglin on 2018/12/13.
//  Copyright © 2018年 quanshi. All rights reserved.
//

#import "GCDAsyncSocketPreBuffer.h"

@implementation GCDAsyncSocketPreBuffer

- (id)initWithCapacity:(size_t)numBytes
{
    if ((self = [super init]))
    {
        preBufferSize = numBytes;
        preBuffer = malloc(preBufferSize);
        
        readPointer = preBuffer;
        writePointer = preBuffer;
    }
    return self;
}

- (void)dealloc
{
    if (preBuffer)
        free(preBuffer);
}

- (void)ensureCapacityForWrite:(size_t)numBytes
{
    size_t availableSpace = [self availableSpace];
    
    if (numBytes > availableSpace)
    {
        size_t additionalBytes = numBytes - availableSpace;
        
        size_t newPreBufferSize = preBufferSize + additionalBytes;
        uint8_t *newPreBuffer = realloc(preBuffer, newPreBufferSize);
        
        size_t readPointerOffset = readPointer - preBuffer;
        size_t writePointerOffset = writePointer - preBuffer;
        
        preBuffer = newPreBuffer;
        preBufferSize = newPreBufferSize;
        
        readPointer = preBuffer + readPointerOffset;
        writePointer = preBuffer + writePointerOffset;
    }
}

- (size_t)availableBytes
{
    return writePointer - readPointer;
}

- (uint8_t *)readBuffer
{
    return readPointer;
}

- (void)getReadBuffer:(uint8_t **)bufferPtr availableBytes:(size_t *)availableBytesPtr
{
    if (bufferPtr) *bufferPtr = readPointer;
    if (availableBytesPtr) *availableBytesPtr = [self availableBytes];
}

- (void)didRead:(size_t)bytesRead
{
    readPointer += bytesRead;
    
    if (readPointer == writePointer)
    {
        // The prebuffer has been drained. Reset pointers.
        readPointer  = preBuffer;
        writePointer = preBuffer;
    }
}

- (size_t)availableSpace
{
    return preBufferSize - (writePointer - preBuffer);
}

- (uint8_t *)writeBuffer
{
    return writePointer;
}

- (void)getWriteBuffer:(uint8_t **)bufferPtr availableSpace:(size_t *)availableSpacePtr
{
    if (bufferPtr) *bufferPtr = writePointer;
    if (availableSpacePtr) *availableSpacePtr = [self availableSpace];
}

- (void)didWrite:(size_t)bytesWritten
{
    writePointer += bytesWritten;
}

- (void)reset
{
    readPointer  = preBuffer;
    writePointer = preBuffer;
}

@end
