//
//  BCPSFolder.h
//  PhotoShare
//
//  Created by Nalinda Somasundara on 11/3/14.
//
//

#import <Foundation/Foundation.h>
@class Folder;

@interface BCPSFolder : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *parentFolderName;

@property (nonatomic, strong) Folder *folder;

@property (nonatomic, assign) BOOL isLeaf;

- (instancetype)initWithName:(NSString *)name parentFolderName:(NSString *)parentName NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString *)name parentFolderName:(NSString *)parentName isLeaf:(BOOL)isLeaf;

@end
