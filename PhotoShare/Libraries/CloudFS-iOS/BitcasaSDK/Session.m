//
//  Session.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Session.h"
#import "BitcasaAPI.h"
#import "Credentials.h"
#import "User.h"
#import "Account.h"

@interface Session ()
{
    Credentials* credentials;
}
@end

static Session* _sharedSession = nil;

@implementation Session

+ (Session*)sharedSession
{
    return _sharedSession;
}

- (id)initWithServerURL:(NSString*)url clientId:(NSString*)clientId clientSecret:(NSString*)secret
{
    self = [super init];
    if (self)
    {
        credentials = [[Credentials alloc] initWithServerURL:url clientId:clientId andSecret:secret];
        
        _sharedSession = self;
    }
    return self;
}

- (void)authenticateWithUsername:(NSString*)username andPassword:(NSString*)password completion:(void (^)(BOOL success))completion
{
    NSString* token = [BitcasaAPI accessTokenWithEmail:username password:password];
    [credentials setAccessToken:token];
    
    [BitcasaAPI getProfileWithCompletion:^(NSDictionary* response)
     {
         self.user = [[User alloc] initWithDictionary:response];
         self.account = [[Account alloc] initWithDictionary:response];
         
         if (response)
             completion(YES);
         else
             completion(NO);
     }];
}

- (void)unlink
{
    [credentials setAccessToken:@""];
}

- (BOOL)isLinked
{
    return (credentials.accessToken && ![credentials.accessToken isEqualToString:@""]);
}

@end
