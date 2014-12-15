//
//  BCAssetStream.h
//  BitcasaV2
//
//  Created by Randy Tran on 2/27/13.
//  Copyright (c) 2013 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

/*!
 @class BCAssetStream
 @discussion
 `BCAssetStream` is a subclass of NSInputStream. It is used to wrap NSInputStream around ALAssetRepresentation. It can be used in a request to stream large camera roll files because the assets are sandboxed.
 */

@interface BCAssetStream : NSInputStream <NSCopying>

@property (assign) NSStreamStatus streamStatus;

/*!
 @method
 @param representation
 
 @param library
 */
- (id)initWithAssetRep:(ALAssetRepresentation *)representation fromAssetLibrary:(ALAssetsLibrary *)library;

- (NSString *)filename;
- (long long)contentLength;

@end
