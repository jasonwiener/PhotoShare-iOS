//
//  TransferManager.h
//  BitcasaSDK
//
//  Created by Olga on 9/11/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TransferDelegate;
@interface TransferManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLSession* backgroundSession;
@property (nonatomic, strong) id <TransferDelegate> delegate;

+ (instancetype)sharedManager;
@end
