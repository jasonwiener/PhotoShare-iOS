//
//  BCPSUser.h
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/29/14.
//
//

#import <Foundation/Foundation.h>

// Represents information related to a PhotoShare app user.
@interface BCPSUser : NSObject

// Username of the user.
@property (nonatomic, copy) NSString *username;

// Shared Key of the public folder.
@property (nonatomic, copy) NSString *publicFolderSharedKey;

// The path of the public folder.
@property (nonatomic, copy) NSString *publicFolderPath;

// Friends of this user.
@property (nonatomic, strong) NSMutableArray *friends;

/**
 *  Initializes BCPSUser from given JSON formatted string.
 *
 *  @param json A string in JSON format.
 *
 *  @return Initialized BCPSUser object.
 */
- (instancetype)initWithJSON:(NSString *)json NS_DESIGNATED_INITIALIZER;

/**
 *  Returns JSON Representation of the defined properties.
 *
 *  @return A string in JSON format.
 */
@property (nonatomic, readonly, copy) NSString *JSONRepresentation;

@end
