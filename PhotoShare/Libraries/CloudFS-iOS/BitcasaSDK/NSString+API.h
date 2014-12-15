//
//  NSString+API.h
//  Bitcasa
//
//  Created by Olga Galchenko on 5/12/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (API)

- (NSString*)encode;
- (NSString*)uriEncode;
+ (NSString*)parameterStringWithArray:(NSArray*)parameters;

@end
