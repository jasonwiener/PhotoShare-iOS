//
//  Session.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Account;
@class User;
@class Filesystem;

@protocol DBSessionDelegate;

@interface Session : NSObject

@property (nonatomic, strong) User* user;
@property (nonatomic, strong) Account* account;
@property (nonatomic, strong) Filesystem* fs;
@property (nonatomic, strong) NSArray* shares;

@property (nonatomic, assign) id<DBSessionDelegate> delegate;

+ (Session*)sharedSession;

- (id)initWithServerURL:(NSString*)url clientId:(NSString*)clientId clientSecret:(NSString*)secret;

- (void)authenticateWithUsername:(NSString*)username andPassword:(NSString*)password completion:(void (^)(BOOL success))completion;
- (void)unlink;
- (BOOL)isLinked;

@end

@protocol DBSessionDelegate

- (void)sessionDidReceiveAuthorizationFailure:(Session *)session userId:(NSString *)userId;

@end

