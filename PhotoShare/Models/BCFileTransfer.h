//
//  BCFileTransfer.h
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/19/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class File;

@interface BCFileTransfer : NSObject

/**
 *  Reference to completion block to be excuted when the upload is completed.
 */
@property (nonatomic, copy) void (^uploadCompletion)(File *file, NSString *filename, NSObject *referenceObject, NSError *error);

/**
 *  Reference to completion block to be executed when the download is completed.
 */
@property (nonatomic, copy) void (^downloadCompletion)(NSString *filename, NSObject *referenceObject, NSURL *locationURL, NSError *error);

/**
 *  Reference object to be passed with download and upload handlers.
 */
@property (nonatomic, strong) NSObject *referenceObject;

/**
 *  Filename associated with the transfer.
 */
@property (nonatomic, strong) NSString *filename;


@end
