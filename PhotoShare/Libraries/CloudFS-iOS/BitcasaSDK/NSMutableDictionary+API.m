//
//  NSMutableDictionary+API.m
//  BitcasaSDK
//
//  Created by Howard Chou on 10/27/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "NSMutableDictionary+API.h"
#import "NSString+API.h"

@implementation NSMutableDictionary (API)

- (NSString*)sortedParameterString
{
    NSMutableString* parametersString = [NSMutableString string];
    NSArray* sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString* key in sortedKeys)
    {
        [parametersString appendString:[NSString stringWithFormat:@"%@=%@&", [key encode], [(NSString*)[self objectForKey:key] encode]]];
    }
    [parametersString deleteCharactersInRange:NSMakeRange(parametersString.length-1, 1)];
    return parametersString;
}

@end
