//
//  Credentials.m
//  BitcasaSDK
//
//  Created by Olga on 8/22/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Credentials.h"

static NSString* const kServerURLKey = @"server url key";
static NSString* const kAccessTokenKey = @"access token key";
static NSString* const kClientIDKey = @"client id key";
static NSString* const kClientSecretKey = @"client secret key";

static Credentials* _sharedInstance = nil;

@implementation Credentials

+ (Credentials*)sharedInstance
{
    return _sharedInstance;
}

- (id)initWithServerURL:(NSString*)serverURL clientId:(NSString*)clientId andSecret:(NSString*)secret
{
    self = [super init];
    if (self)
    {
        _appId = clientId;
        _appSecret = secret;
        _serverURL = serverURL;
        _accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey];
        
        _sharedInstance = self;
    }
    return self;
}

- (void)setAccessToken:(NSString*)inAccessToken
{
    _accessToken = inAccessToken;
    
    [[NSUserDefaults standardUserDefaults] setObject:inAccessToken forKey:kAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
