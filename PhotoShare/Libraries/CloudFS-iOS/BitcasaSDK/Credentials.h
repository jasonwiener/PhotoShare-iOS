//
//  Credentials.h
//  BitcasaSDK
//
//  Created by Olga on 8/22/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Credentials : NSObject

@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* appSecret;
@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSString* serverURL;

+ (Credentials*)sharedInstance;
- (id)initWithServerURL:(NSString*)serverURL clientId:(NSString*)clientId andSecret:(NSString*)secret;
- (void)setAccessToken:(NSString*)inAccessToken;
@end
