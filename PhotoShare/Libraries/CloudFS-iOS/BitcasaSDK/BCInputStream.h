//
//  BCInputStream.h
//  Bitcasa
//
//  Created by Randy Tran on 11/21/13.
//  Copyright (c) 2013 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *kBCMultipartFormDataBoundary;

typedef NS_ENUM(NSUInteger, BCInputStreamState) {
    BCInputStreamStateStart,
    BCInputStreamStateHeader,
    BCInputStreamStateAvailable,
    BCInputStreamStateClosing,
    BCInputStreamStateEnd
};

@interface BCInputStream : NSInputStream
{
    NSUInteger offset;
    NSMutableData *savedData;
}

@property (assign, nonatomic) NSUInteger length;

@property (assign) BCInputStreamState inputStreamState;

@property (strong) NSString *filename;

@property (strong) NSInputStream *inputStream;
@property (assign) NSStreamStatus streamStatus;

+ (BCInputStream *)BCInputStreamWithFilename:(NSString *)filename inputStream:(NSInputStream *)inputStream;
- (NSString *)bodyInitialBoundary;
- (NSString *)bodyFormData;
- (NSString *)bodyEndBoundary;

@end
