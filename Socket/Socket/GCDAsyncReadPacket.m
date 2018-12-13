//
//  GCDAsyncReadPacket.m
//  Socket
//
//  Created by fenglin on 2018/12/13.
//  Copyright © 2018年 quanshi. All rights reserved.
//

#import "GCDAsyncReadPacket.h"

@implementation GCDAsyncReadPacket

- (id)initWithData:(NSMutableData *)d
       startOffset:(NSUInteger)s
         maxLength:(NSUInteger)m
           timeout:(NSTimeInterval)t
        readLength:(NSUInteger)l
        terminator:(NSData *)e
               tag:(long)i
{
    if((self = [super init]))
    {
        bytesDone = 0;
        maxLength = m;
        timeout = t;
        readLength = l;
        term = [e copy];
        tag = i;
        
        if (d)
        {
            buffer = d;
            startOffset = s;
            bufferOwner = NO;
            originalBufferLength = [d length];
        }
        else
        {
            if (readLength > 0)
                buffer = [[NSMutableData alloc] initWithLength:readLength];
            else
                buffer = [[NSMutableData alloc] initWithLength:0];
            
            startOffset = 0;
            bufferOwner = YES;
            originalBufferLength = 0;
        }
    }
    return self;
}

/**
 * Increases the length of the buffer (if needed) to ensure a read of the given size will fit.
 **/
- (void)ensureCapacityForAdditionalDataOfLength:(NSUInteger)bytesToRead
{
    NSUInteger buffSize = [buffer length];
    NSUInteger buffUsed = startOffset + bytesDone;
    
    NSUInteger buffSpace = buffSize - buffUsed;
    
    if (bytesToRead > buffSpace)
    {
        NSUInteger buffInc = bytesToRead - buffSpace;
        
        [buffer increaseLengthBy:buffInc];
    }
}

/**
 * This method is used when we do NOT know how much data is available to be read from the socket.
 * This method returns the default value unless it exceeds the specified readLength or maxLength.
 *
 * Furthermore, the shouldPreBuffer decision is based upon the packet type,
 * and whether the returned value would fit in the current buffer without requiring a resize of the buffer.
 **/
- (NSUInteger)optimalReadLengthWithDefault:(NSUInteger)defaultValue shouldPreBuffer:(BOOL *)shouldPreBufferPtr
{
    NSUInteger result;
    
    if (readLength > 0)
    {
        // Read a specific length of data
        result = readLength - bytesDone;
        
        // There is no need to prebuffer since we know exactly how much data we need to read.
        // Even if the buffer isn't currently big enough to fit this amount of data,
        // it would have to be resized eventually anyway.
        
        if (shouldPreBufferPtr)
            *shouldPreBufferPtr = NO;
    }
    else
    {
        // Either reading until we find a specified terminator(特殊终结字符),
        // or we're simply reading all available data.
        //
        // In other words, one of:
        //
        // - readDataToData packet
        // - readDataWithTimeout packet
        
        if (maxLength > 0)
            result =  MIN(defaultValue, (maxLength - bytesDone));
        else
            result = defaultValue;
        
        // Since we don't know the size of the read in advance,
        // the shouldPreBuffer decision is based upon whether the returned value would fit
        // in the current buffer without requiring a resize of the buffer.
        //
        // This is because, in all likelyhood（无论如何）, the amount read from the socket will be less than the default value.
        // Thus we should avoid over-allocating（过度分配） the read buffer when we can simply use the pre-buffer instead.
        
        if (shouldPreBufferPtr)
        {
            NSUInteger buffSize = [buffer length];
            NSUInteger buffUsed = startOffset + bytesDone;
            
            NSUInteger buffSpace = buffSize - buffUsed;
            
            if (buffSpace >= result)
                *shouldPreBufferPtr = NO;
            else
                *shouldPreBufferPtr = YES;
        }
    }
    
    return result;
}

/**
 * 读包（没有终结字符集合）
 * For read packets without a set terminator, returns the amount of data
 * that can be read without exceeding （超过） the readLength or maxLength.
 *
 * The given parameter indicates the number of bytes estimated（估计) to be available on the socket,
 * which is taken into consideration during the calculation.
 *
 * The given hint (提示) MUST be greater than zero.
 **/
- (NSUInteger)readLengthForNonTermWithHint:(NSUInteger)bytesAvailable
{
    NSAssert(term == nil, @"This method does not apply to term reads");
    NSAssert(bytesAvailable > 0, @"Invalid parameter: bytesAvailable");
    
    if (readLength > 0)
    {
        // Read a specific length of data
        
        return MIN(bytesAvailable, (readLength - bytesDone));
        
        // No need to avoid resizing the buffer.
        // If the user provided their own buffer,
        // and told us to read a certain length of data that exceeds the size of the buffer,
        // then it is clear that our code will resize the buffer during the read operation.
        //
        // This method does not actually do any resizing.
        // The resizing will happen elsewhere if needed.
    }
    else
    {
        // Read all available data
        
        NSUInteger result = bytesAvailable;
        
        if (maxLength > 0)
        {
            result = MIN(result, (maxLength - bytesDone));
        }
        
        // No need to avoid resizing the buffer.
        // If the user provided their own buffer,
        // and told us to read all available data without giving us a maxLength,
        // then it is clear that our code might resize the buffer during the read operation.
        //
        // This method does not actually do any resizing.
        // The resizing will happen elsewhere if needed.
        
        return result;
    }
}

/**
 * For read packets with a set terminator, returns the amount of data
 * that can be read without exceeding the maxLength.
 *
 * The given parameter indicates the number of bytes estimated (估计) to be available on the socket,
 * which is taken into consideration during the calculation.
 *
 * To optimize memory allocations, mem copies, and mem moves
 * the shouldPreBuffer boolean value will indicate if the data should be read into a prebuffer first,
 * or if the data can be read directly into the read packet's buffer.
 **/
- (NSUInteger)readLengthForTermWithHint:(NSUInteger)bytesAvailable shouldPreBuffer:(BOOL *)shouldPreBufferPtr
{
    NSAssert(term != nil, @"This method does not apply to non-term reads");
    NSAssert(bytesAvailable > 0, @"Invalid parameter: bytesAvailable");
    
    
    NSUInteger result = bytesAvailable;
    
    if (maxLength > 0)
    {
        result = MIN(result, (maxLength - bytesDone));
    }
    
    // Should the data be read into the read packet's buffer, or into a pre-buffer first?
    //
    // One would imagine （想象一下）the preferred option is the faster one.
    // So which one is faster?
    //
    // Reading directly into the packet's buffer requires:
    // 1. Possibly resizing packet buffer (malloc/realloc) 可能调整包缓冲区的大小
    // 2. Filling buffer (read) 填满缓冲区
    // 3. Searching for term (memcmp)
    // 4. Possibly copying overflow into prebuffer (malloc/realloc, memcpy) 可能将溢出复制到预缓冲区
    //
    // Reading into prebuffer first:
    // 1. Possibly resizing prebuffer (malloc/realloc)
    // 2. Filling buffer (read)
    // 3. Searching for term (memcmp)
    // 4. Copying underflow into packet buffer (malloc/realloc, memcpy) 将 底流 复制到包缓冲区
    // 5. Removing underflow from prebuffer (memmove) 从预缓冲区中去除底流
    //
    // Comparing the performance （性能）of the two we can see that reading
    // data into the prebuffer first is slower due to the extra memove.
    //
    // However:
    // The implementation of NSMutableData is open source via core foundation's CFMutableData.
    // Decreasing （减少）the length of a mutable data object doesn't cause a realloc.
    // In other words, the capacity of a mutable data object can grow （成长）, but doesn't shrink（缩小）.
    //
    // This means the prebuffer will rarely need a realloc.
    // The packet buffer, on the other hand, may often need a realloc.
    // This is especially true if we are the buffer owner. 如果我们是缓冲区所有者，这一点尤其正确
    // Furthermore（此外）, if we are constantly （不断地） realloc'ing the packet buffer, 如果我们不断地重新分配包缓冲区，
    // and then moving the overflow into the prebuffer, 然后将溢出部分移动到预缓冲区
    // then we're consistently over-allocating memory for each term read. 然后我们总是为每一个读项分配过多的内存
    // And now we get into a bit of a tradeoff（权衡） between speed and memory utilization. 现在我们要在速度和内存利用率之间进行一些权衡
    // The end result is that the two perform very similarly. 最终的结果是，两者的表现非常相似。
    // And we can answer the original question very simply by another means. 我们可以用另一种方法很简单地回答最初的问题。
    //
    // If we can read all the data directly into the packet's buffer without resizing it first,
    // then we do so. Otherwise we use the prebuffer.
    
    if (shouldPreBufferPtr)
    {
        NSUInteger buffSize = [buffer length];
        NSUInteger buffUsed = startOffset + bytesDone;
        
        if ((buffSize - buffUsed) >= result)
            *shouldPreBufferPtr = NO;
        else
            *shouldPreBufferPtr = YES;
    }
    
    return result;
}

/**
 * For read packets with a set terminator,
 * returns the amount of data that can be read from the given preBuffer,
 * without going over a terminator or the maxLength.
 *
 * It is assumed the terminator has not already been read.
 **/
- (NSUInteger)readLengthForTermWithPreBuffer:(GCDAsyncSocketPreBuffer *)preBuffer found:(BOOL *)foundPtr
{
    NSAssert(term != nil, @"This method does not apply to non-term reads");
    NSAssert([preBuffer availableBytes] > 0, @"Invoked with empty pre buffer!");
    
    // We know that the terminator, as a whole, doesn't exist in our own buffer.
    // But it is possible that a _portion_ of it exists in our buffer.
    // So we're going to look for the terminator starting with a portion of our own buffer.
    //
    // Example:
    //
    // term length      = 3 bytes
    // bytesDone        = 5 bytes
    // preBuffer length = 5 bytes
    //
    // If we append the preBuffer to our buffer,
    // it would look like this:
    //
    // ---------------------
    // |B|B|B|B|B|P|P|P|P|P|
    // ---------------------
    //
    // So we start our search here:
    //
    // ---------------------
    // |B|B|B|B|B|P|P|P|P|P|
    // -------^-^-^---------
    //
    // And move forwards...
    //
    // ---------------------
    // |B|B|B|B|B|P|P|P|P|P|
    // ---------^-^-^-------
    //
    // Until we find the terminator or reach the end.
    //
    // ---------------------
    // |B|B|B|B|B|P|P|P|P|P|
    // ---------------^-^-^-
    
    BOOL found = NO;
    
    NSUInteger termLength = [term length];
    NSUInteger preBufferLength = [preBuffer availableBytes];
    
    if ((bytesDone + preBufferLength) < termLength)
    {
        // Not enough data for a full term sequence yet
        return preBufferLength;
    }
    
    NSUInteger maxPreBufferLength;
    if (maxLength > 0) {
        maxPreBufferLength = MIN(preBufferLength, (maxLength - bytesDone));
        
        // Note: maxLength >= termLength
    }
    else {
        maxPreBufferLength = preBufferLength;
    }
    
    uint8_t seq[termLength];
    const void *termBuf = [term bytes];
    
    NSUInteger bufLen = MIN(bytesDone, (termLength - 1));
    uint8_t *buf = (uint8_t *)[buffer mutableBytes] + startOffset + bytesDone - bufLen;
    
    NSUInteger preLen = termLength - bufLen;
    const uint8_t *pre = [preBuffer readBuffer];
    
    NSUInteger loopCount = bufLen + maxPreBufferLength - termLength + 1; // Plus one. See example above.
    
    NSUInteger result = maxPreBufferLength;
    
    NSUInteger i;
    for (i = 0; i < loopCount; i++)
    {
        if (bufLen > 0)
        {
            // Combining bytes from buffer and preBuffer
            
            memcpy(seq, buf, bufLen);
            memcpy(seq + bufLen, pre, preLen);
            
            if (memcmp(seq, termBuf, termLength) == 0)
            {
                result = preLen;
                found = YES;
                break;
            }
            
            buf++;
            bufLen--;
            preLen++;
        }
        else
        {
            // Comparing directly from preBuffer
            
            if (memcmp(pre, termBuf, termLength) == 0)
            {
                NSUInteger preOffset = pre - [preBuffer readBuffer]; // pointer arithmetic
                
                result = preOffset + termLength;
                found = YES;
                break;
            }
            
            pre++;
        }
    }
    
    // There is no need to avoid resizing the buffer in this particular situation.
    
    if (foundPtr) *foundPtr = found;
    return result;
}

/**
 * For read packets with a set terminator, scans the packet buffer for the term.
 * It is assumed the terminator had not been fully read prior to the new bytes.
 *
 * If the term is found, the number of excess bytes after the term are returned.
 * If the term is not found, this method will return -1.
 *
 * Note: A return value of zero means the term was found at the very end.
 *
 * Prerequisites:
 * The given number of bytes have been added to the end of our buffer.
 * Our bytesDone variable has NOT been changed due to the prebuffered bytes.
 **/
- (NSInteger)searchForTermAfterPreBuffering:(ssize_t)numBytes
{
    NSAssert(term != nil, @"This method does not apply to non-term reads");
    
    // The implementation of this method is very similar to the above method.
    // See the above method for a discussion of the algorithm used here.
    
    uint8_t *buff = [buffer mutableBytes];
    NSUInteger buffLength = bytesDone + numBytes;
    
    const void *termBuff = [term bytes];
    NSUInteger termLength = [term length];
    
    // Note: We are dealing with unsigned integers,
    // so make sure the math doesn't go below zero.
    
    NSUInteger i = ((buffLength - numBytes) >= termLength) ? (buffLength - numBytes - termLength + 1) : 0;
    
    while (i + termLength <= buffLength)
    {
        uint8_t *subBuffer = buff + startOffset + i;
        
        if (memcmp(subBuffer, termBuff, termLength) == 0)
        {
            return buffLength - (i + termLength);
        }
        
        i++;
    }
    
    return -1;
}


@end
