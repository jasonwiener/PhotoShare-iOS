//
//  User.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize email;
@synthesize firstName;
@synthesize lastName;

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.email = dict[@"username"];
        self.firstName = dict[@"first_name"];
        self.lastName = dict[@"last_name"];
    }
    return self;
}

@end
