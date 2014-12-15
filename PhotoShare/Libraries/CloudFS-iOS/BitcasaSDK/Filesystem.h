//
//  Filesystem.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Container;
@interface Filesystem : NSObject

#pragma mark - list
- (void)listItemsInContainer:(Container*)container completion:(void (^)(NSArray* items))completion;

#pragma mark - list trash
- (void)listItemsInTrashWithCompletion:(void (^)(NSArray* items))completion;

#pragma mark - delete
- (void)deleteItems:(NSArray*)items completion:(void (^)(NSArray* successArray))completion;

#pragma mark - move
- (void)moveItems:(NSArray*)items toContainer:(Container*)destinationContainer completion:(void (^)(NSArray* successArray))completion;

#pragma mark - copy
- (void)copyItems:(NSArray*)items toContainer:(Container*)destinationContainer completion:(void (^)(NSArray* successArray))completion;

#pragma mark - share
- (void)listSharesWithCompletion:(void (^)(NSArray* shares))completion;

@end
