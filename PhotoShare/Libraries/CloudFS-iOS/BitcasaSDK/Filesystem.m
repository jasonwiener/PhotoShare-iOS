//
//  Filesystem.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Filesystem.h"
#import "Container.h"
#import "Item.h"
#import "BitcasaAPI.h"

@implementation Filesystem

#pragma mark - list
- (void)listItemsInContainer:(Container*)container completion:(void (^)(NSArray* items))completion
{
    [container listItemsWithCompletion:completion];
}

#pragma mark - list trash
- (void)listItemsInTrashWithCompletion:(void (^)(NSArray* items))completion
{
    [BitcasaAPI getContentsOfTrashWithCompletion:completion];
}

#pragma mark - delete
- (void)deleteItems:(NSArray*)items completion:(void (^)(NSArray* successArray))completion
{
    [BitcasaAPI deleteItems:items completion:completion];
}

#pragma mark - move
- (void)moveItems:(NSArray*)items toContainer:(Container*)destinationContainer completion:(void (^)(NSArray* successArray))completion
{
    [BitcasaAPI moveItems:items to:destinationContainer completion:completion];
}

#pragma mark - copy
- (void)copyItems:(NSArray*)items toContainer:(Container*)destinationContainer completion:(void (^)(NSArray* successArray))completion
{
    [BitcasaAPI copyItems:items to:destinationContainer completion:completion];
}

#pragma mark - shares
- (void)listSharesWithCompletion:(void (^)(NSArray* shares))completion
{
    [BitcasaAPI listShares:completion];
}
@end
