//
//  Share.h
//  BitcasaSDK
//
//  Created by Howard Chou on 10/16/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Container.h"

@interface Share : NSObject

@property (nonatomic, strong) NSString* shareKey;
@property (nonatomic) NSNumber* size;

@property (nonatomic) NSString* itemId;
@property (nonatomic) NSString* parentId;
@property (nonatomic) NSString* type;
@property (nonatomic) NSString* name;
@property (nonatomic) NSDate* dateCreated;
@property (nonatomic) NSDate* dateMetaLastModified;
@property (nonatomic) NSDate* dateContentLastModified;
@property (nonatomic) int64_t version;

- (Share*)initWithDictionary:(NSDictionary*)dictionary;
- (void)getMetaWithDictionary:(NSDictionary *)dictionary;
- (void)listItemsWithCompletion: (void (^) (NSArray* items))completion;

@end
