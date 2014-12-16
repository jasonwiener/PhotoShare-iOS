//
//  Container.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Folder.h"
#import "BitcasaAPI.h"

NSString* const kAPIEndpointFolderAction = @"/folders";

@implementation Container
@synthesize itemCount;

- (id)initRootContainer
{
    self = [super init];
    if (self)
    {
        [self setUrl:@"/"];
    }
    return self;
}

#pragma mark - create folder
- (void) createFolder:(NSString*)name completion:(void (^)(Folder* newDir))completion
{
    [BitcasaAPI createFolderInContainer:self withName:name completion:^(NSDictionary* newContainerDict)
    {
        if (newContainerDict == nil)
            completion(nil);
        
        Folder* newDir = [[Folder alloc] initWithDictionary:newContainerDict andParentContainer:self];
        completion(newDir);
    }];
}

#pragma mark - list items
- (void) listItemsWithCompletion:(void (^)(NSArray* items))completion
{
    [BitcasaAPI getContentsOfContainer:self completion:completion];
}

- (NSString*)endpointPath
{
    return [NSString stringWithFormat:@"%@%@", kAPIEndpointFolderAction, self.url];
}
@end
