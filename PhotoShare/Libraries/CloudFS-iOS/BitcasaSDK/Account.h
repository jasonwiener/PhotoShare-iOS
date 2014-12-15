//
//  Account.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic, strong) NSNumber* usage;
@property (nonatomic, strong) NSNumber* quota;
@property (nonatomic, strong) NSString* planName;
- (id)initWithDictionary:(NSDictionary*)dictionary;
@end
