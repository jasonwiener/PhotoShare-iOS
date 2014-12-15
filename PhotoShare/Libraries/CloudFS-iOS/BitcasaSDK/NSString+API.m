//
//  NSString+API.m
//  Bitcasa
//
//  Created by Olga Galchenko on 5/12/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "NSString+API.h"

@implementation NSString (API)

- (NSString*)encode
{
    NSMutableCharacterSet* urlSafeCharacters = [NSMutableCharacterSet characterSetWithCharactersInString:@".-*_"];
   [urlSafeCharacters formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    NSString* encodedStr = [self stringByAddingPercentEncodingWithAllowedCharacters:urlSafeCharacters];
    return [encodedStr stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
}

- (NSString*)uriEncode
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
}

+ (NSString*)parameterStringWithArray:(NSArray*)parameters
{
    NSMutableString* allParams = [NSMutableString string];
    
    [parameters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSDictionary* oneParam = (NSDictionary*)obj;
         NSString* paramValue = [[oneParam allValues] firstObject];
         paramValue = [paramValue encode];
         [allParams appendString:[NSString stringWithFormat:@"%@=%@&", [[oneParam allKeys] firstObject], paramValue]];
     }];
    
    [allParams deleteCharactersInRange:NSMakeRange(allParams.length-1, 1)];
    return allParams;
}


@end
