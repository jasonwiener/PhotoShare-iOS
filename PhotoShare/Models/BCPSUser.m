//
//  BCPSUser.m
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/29/14.
//
//

#import "BCPSUser.h"

@implementation BCPSUser

static NSString *const usernameField = @"username";
static NSString *const publicFolderSharedKeyField = @"publicFolderSharedKey";
static NSString *const friendsField = @"friends";
static NSString *const publicFolderPathField = @"publicFolderPath";

- (instancetype)initWithJSON:(NSString *)json
{
    self = [super init];
    
    if (self)
    {
        NSError *jsonError;
        NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:&jsonError];
        self.username = dictionary[usernameField];
        self.publicFolderSharedKey = dictionary[publicFolderSharedKeyField];
        self.friends = ([dictionary[friendsField] isKindOfClass:[NSString class]]) ? nil : dictionary[friendsField];
        self.publicFolderPath = dictionary[publicFolderPathField];
    }
    
    return self;
}

- (NSString *)JSONRepresentation
{
    NSDictionary *dictionary = @{usernameField: (self.username == nil ? @"" : self.username),
                                friendsField: (self.friends == nil ? @"" : self.friends),
                                publicFolderSharedKeyField: (self.publicFolderSharedKey == nil ? @"" : self.publicFolderSharedKey),
                                publicFolderPathField: (self.publicFolderPath == nil ? @"" : self.publicFolderPath)};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
