//
//  BCInputStream.m
//  Bitcasa
//
//  Created by Randy Tran on 11/21/13.
//  Copyright (c) 2013 Bitcasa. All rights reserved.
//

#import "BCInputStream.h"
#import <MobileCoreServices/MobileCoreServices.h>

NSString const *kBCMultipartFormDataBoundary = @"AaB03x";

@implementation BCInputStream
@synthesize streamStatus;

+ (BCInputStream *)BCInputStreamWithFilename:(NSString *)filename inputStream:(NSInputStream *)inputStream
{
    BCInputStream *stream = [[BCInputStream alloc] init];
    stream.filename = filename;
    stream.inputStream = inputStream;
    return stream;
}

- (NSString *)bodyInitialBoundary
{
    return [NSMutableString stringWithFormat:@"\r\n--%@\r\n", kBCMultipartFormDataBoundary];
}

- (NSString *)bodyFormData
{
    NSMutableString* formString = [NSMutableString string];
    [formString appendFormat:@"Content-Disposition: form-data; name=\"exists\"\r\n"];
    [formString appendFormat:@"Content-type: text/plain; charset=UTF-8\r\n\r\n%@\r\n", @"rename"];
    [formString appendFormat:@"--%@\r\n", kBCMultipartFormDataBoundary];
    [formString appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", self.filename];
    [formString appendFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"];
    return formString;
}

- (NSString*)fileMIMEType:(NSString*)file
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[file pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    return (__bridge NSString*)MIMEType;
}

- (NSString *)bodyEndBoundary
{
    return [NSString stringWithFormat:@"\r\n--%@--\r\n", kBCMultipartFormDataBoundary];
}

- (void)open
{
    savedData = [NSMutableData data];
    
    self.streamStatus = NSStreamStatusOpening;
    
    [self.inputStream open];
    
    self.streamStatus = NSStreamStatusOpen;
}

- (void)close
{
    [self.inputStream close];
    
    self.streamStatus = NSStreamStatusClosed;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    return NO;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    self.streamStatus = NSStreamStatusReading;
    NSMutableData *totalData = [NSMutableData dataWithCapacity:len];
    NSUInteger remainingLength = len;
    
    if (_inputStreamState == BCInputStreamStateStart)
    {
        NSData *data = [[self bodyInitialBoundary] dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger dataLength = MIN(([data length] - offset), remainingLength);
        data = [data subdataWithRange:NSMakeRange(offset, dataLength)];
        
        [totalData appendData:data];
        offset += [data length];
        remainingLength -= [data length];
        
        if (offset >= [data length])
        {
            offset = 0;
            _inputStreamState = BCInputStreamStateHeader;
        }
    }
    
    if (_inputStreamState == BCInputStreamStateHeader)
    {
        NSData *data = [[self bodyFormData] dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger dataLength = MIN(([data length] - offset), remainingLength);
        data = [data subdataWithRange:NSMakeRange(offset, dataLength)];
        
        [totalData appendData:data];
        offset += [data length];
        remainingLength -= [data length];
        
        if (offset >= [data length])
        {
            offset = 0;
            _inputStreamState = BCInputStreamStateAvailable;
        }
    }
    
    if (_inputStreamState == BCInputStreamStateAvailable)
    {
        uint8_t databuf[remainingLength];
        NSUInteger dataLength = [self.inputStream read:databuf maxLength:remainingLength];
        
        NSData *data = [NSData dataWithBytes:databuf length:dataLength];
        remainingLength -= [data length];
        
        [totalData appendData:data];
        
        if (![self.inputStream hasBytesAvailable])
        {
            _inputStreamState = BCInputStreamStateClosing;
        }
    }
    
    if (_inputStreamState == BCInputStreamStateClosing)
    {
        NSData *data = [[self bodyEndBoundary] dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger dataLength = MIN(([data length] - offset), remainingLength);
        data = [data subdataWithRange:NSMakeRange(offset, dataLength)];
        
        [totalData appendData:data];
        offset += [data length];
        
        if (offset >= [data length])
        {
            _inputStreamState = BCInputStreamStateEnd;
            
            self.streamStatus = NSStreamStatusAtEnd;
        }
    }
    
    [totalData getBytes:buffer length:MIN(len, [totalData length])];
    
    return [totalData length];
}

- (BOOL)hasBytesAvailable
{
    if (_inputStreamState == BCInputStreamStateEnd)
    {
        return NO;
    }
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    BCInputStream *stream = [[BCInputStream alloc] init];
    stream.inputStream = [self.inputStream copy];
    stream.filename = [self.filename copy];
    
    return stream;
}

- (void)_scheduleInCFRunLoop:(__unused CFRunLoopRef)aRunLoop forMode:(__unused CFStringRef)aMode
{
}

- (void)_unscheduleFromCFRunLoop:(__unused CFRunLoopRef)aRunLoop forMode:(__unused CFStringRef)aMode
{
}

- (BOOL)_setCFClientFlags:(__unused CFOptionFlags)inFlags callback:(__unused CFReadStreamClientCallBack)inCallback context:(__unused CFStreamClientContext *)inContext
{
    return NO;
}

@end
