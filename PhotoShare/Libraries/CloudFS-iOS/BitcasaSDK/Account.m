//
//  Account.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Account.h"

@implementation Account
@synthesize usage;
@synthesize quota;
@synthesize planName;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        NSDictionary* storageDict = dictionary[@"storage"];
        self.usage = storageDict[@"usage"];
        self.quota = storageDict[@"limit"];
        self.planName = dictionary[@"account_plan"][@"display_name"];
    }
    return self;
}
@end
