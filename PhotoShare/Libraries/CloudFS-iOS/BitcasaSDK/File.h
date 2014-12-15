//
//  File.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

extern NSString* const kAPIEndpointFileAction;

@protocol TransferDelegate;
@interface File : Item

@property (nonatomic, retain) NSString * mime;
@property (nonatomic, retain) NSString * extension;
@property (nonatomic) NSNumber* size;

- (void)downloadWithDelegate:(id <TransferDelegate>)delegate;

@end
