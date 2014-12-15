//
//  User.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;

- (id)initWithDictionary:(NSDictionary*)dict;
@end
