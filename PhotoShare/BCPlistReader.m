//
//  BCPlistReader.m
//  PhotoShare
//
//  Created by Chathurka on 10/23/14.
//
//

#import "BCPlistReader.h"

@implementation BCPlistReader
{
    NSString *_fileName;
}

- (instancetype)initWithFileName:(NSString *) fileName
{
    if (self = [super init])
    {
        _fileName = fileName;
    }
    
    return self;
}

- (id)appConfigValueForKey:(NSString *)key
{
    if (key.length > 0)
    {
        return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_fileName ofType:@"plist"]][key];
    }
    
    return nil;
}

@end
