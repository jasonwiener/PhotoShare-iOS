//
//  Container.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

extern NSString* const kAPIEndpointFolderAction;

@interface Container : Item

@property (nonatomic) int64_t itemCount;

- (id)initRootContainer;
- (void) createFolder:(NSString*)name completion:(void (^)(Container* newDir))completion;
- (void) listItemsWithCompletion:(void (^)(NSArray* items))completion;
@end
