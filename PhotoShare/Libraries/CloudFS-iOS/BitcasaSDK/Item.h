//
//  Item.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Container;
@class Share;
@interface Item : NSObject

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* parentId;
@property (nonatomic) int64_t version;
@property (nonatomic, retain) NSString* name;
@property (nonatomic) NSDate* dateContentLastModified;
@property (nonatomic) NSDate* dateCreated;

- (id)initWithDictionary:(NSDictionary*)dict andParentContainer:(Container*)parent;
- (id)initWithDictionary:(NSDictionary*)dict andParentPath:(NSString*)parentPath;

#pragma mark - copy
- (void)copyToDestinationContainer:(Container *)destContainer completion:(void (^)(Item* newItem))completion;

#pragma mark - move
- (void)moveToDestinationContainer:(Container *)destContainer completion:(void (^)(Item * movedItem))completion;

#pragma mark - share
- (void)shareWithCompletion:(void (^)(Share* share))completion;

#pragma mark - delete
- (void)deleteWithCompletion:(void (^)(BOOL success))completion;

#pragma mark - restore
- (void)restoreToContainer:(Container*)container completion:(void (^)(BOOL))completion;

- (NSString*)endpointPath;

@end
