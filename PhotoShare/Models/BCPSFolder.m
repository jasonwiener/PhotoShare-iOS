//
//  BCPSFolder.m
//  PhotoShare
//
//  Created by Nalinda Somasundara on 11/3/14.
//
//

#import "BCPSFolder.h"

@implementation BCPSFolder

- (instancetype)initWithName:(NSString *)name
            parentFolderName:(NSString *)parentName
{
    self = [super init];
    if (self) {
        self.name = name;
        self.parentFolderName = parentName;
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name
            parentFolderName:(NSString *)parentName
                      isLeaf:(BOOL)isLeaf
{
    self = [self initWithName:name parentFolderName:parentName];
    if (self) {
        self.isLeaf = isLeaf;
    }
    
    return self;
}

@end
