//
//  Share.m
//  BitcasaSDK
//
//  Created by Howard Chou on 10/16/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Share.h"
#import "File.h"
#import "Folder.h"
#import "BitcasaAPI.h"

@implementation Share

@synthesize shareKey;
@synthesize size;

- (Share*)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.shareKey = dictionary[@"share_key"];
        self.size = dictionary[@"size"];
        self.dateCreated = dictionary[@"date_created"];
    }
    return self;
}

- (void)getMetaWithDictionary:(NSDictionary *)dictionary
{
    self.itemId = dictionary[@"id"];
    self.parentId = dictionary[@"parent_id"];
    self.type = dictionary[@"type"];
    self.name = dictionary[@"name"];
    self.dateCreated = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"date_created"] doubleValue]];
    self.dateMetaLastModified = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"date_meta_last_modified"] doubleValue]];
    self.dateContentLastModified = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"date_content_last_modified"] doubleValue]];
    self.version = [dictionary[@"version"] integerValue];
}

- (void)listItemsWithCompletion: (void (^) (NSArray* items))completion
{
    [BitcasaAPI browseShare:self completion:completion];
}

@end
