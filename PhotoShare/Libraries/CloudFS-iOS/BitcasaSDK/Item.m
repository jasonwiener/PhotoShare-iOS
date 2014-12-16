//
//  Item.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Item.h"
#import "BitcasaAPI.h"
#import "Container.h"

@implementation Item

@synthesize url;
@synthesize parentId;
@synthesize version;
@synthesize name;
@synthesize dateContentLastModified;
@synthesize dateCreated;

- (id)initWithDictionary:(NSDictionary*)dict andParentContainer:(Container*)parent
{
    return [self initWithDictionary:dict andParentPath:parent.url];
}

- (id)initWithDictionary:(NSDictionary*)dict andParentPath:(NSString*)parentPath
{
    self = [super init];
    if (self)
    {
        self.name = dict[@"name"];
        self.dateContentLastModified = [NSDate dateWithTimeIntervalSince1970:[dict[@"date_content_last_modified"] doubleValue]];
        self.dateCreated = [NSDate dateWithTimeIntervalSince1970:[dict[@"date_created"] doubleValue]];
        self.version = [dict[@"version"] integerValue];
        self.parentId = dict[@"parent_id"];
        self.url = [parentPath stringByAppendingPathComponent:dict[@"id"]];
    }
    return self;
}

#pragma mark - copy
- (void)copyToDestinationContainer:(Container *)destContainer completion:(void (^)(Item *))completion
{
    [BitcasaAPI copyItem:self to:destContainer completion:completion];
}

#pragma mark - move
- (void)moveToDestinationContainer:(Container *)destContainer completion:(void (^)(Item * movedItem))completion
{
    [BitcasaAPI moveItem:self to:destContainer completion:completion];
}

#pragma mark - share
- (void)shareWithCompletion:(void (^)(Share* share))completion
{
    [BitcasaAPI shareItems:@[self] completion:completion];
}

#pragma mark - delete
- (void)deleteWithCompletion:(void (^)(BOOL))completion
{
    [BitcasaAPI deleteItem:self completion:completion];
}

#pragma mark - restore
- (void)restoreToContainer:(Container*)container completion:(void (^)(BOOL))completion
{
    [BitcasaAPI restoreItem:self to:container completion:completion];
}

- (NSString*)endpointPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Item class: %@; name = %@; url = %@; version = %qi", [self class], self.name, self.url, self.version];
}
@end
