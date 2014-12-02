//
//  BCPhotoShareItem.m
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/23/14.
//
//

#import "BCPSPhoto.h"

@implementation BCPSPhoto

static NSString *const captionField = @"caption";
static NSString *const likedUsersField = @"likedUsers";
static NSString *const usernameField = @"username";
static NSString *const uuidField = @"uuid";
static NSString *const isSharedFeild = @"isShared";
static NSString *const sharedTimeFeild = @"sharedTime";

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self && (dictionary != nil) && [dictionary count])
    {
        self.caption = dictionary[captionField];
        
        if ([dictionary[likedUsersField] isKindOfClass:[NSString class]])
        {
            self.likedUsers = [NSMutableArray array];
        }
        else
        {
              self.likedUsers = [NSMutableArray arrayWithArray:dictionary[likedUsersField]];
        }
        
        self.username = dictionary[usernameField];
        self.uuid = dictionary[uuidField];
        self.isShared = [dictionary[isSharedFeild] boolValue];
        self.sharedTime = dictionary[sharedTimeFeild] == nil ? 0: [dictionary[sharedTimeFeild] doubleValue];
    }
    
    return self;
}

- (instancetype)initWithJSON:(NSString *)json
{
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:nil];
    return [self initWithDictionary:dictionary];
}

- (NSString *)JSONRepresentation
{
    NSDictionary *dictionary = [self dictionaryRepresentation];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSDictionary *dictionary = @{captionField: (self.caption == nil ? @"" : self.caption),
                                likedUsersField: (self.likedUsers == nil ? @"" : self.likedUsers),
                                usernameField: (self.username == nil ? @"" : self.username),
                                uuidField: (self.uuid == nil ? @"": self.uuid),
                                sharedTimeFeild: @(self.sharedTime),
                                isSharedFeild: @(self.isShared)};
    
    
    
    return dictionary;
}

- (NSComparisonResult)compare:(BCPSPhoto *)otherObject
{
    return self.sharedTime > otherObject.sharedTime;
}


@end
