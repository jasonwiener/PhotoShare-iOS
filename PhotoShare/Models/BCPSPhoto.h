//
//  BCPhotoShareItem.h
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/23/14.
//
//

#import <Foundation/Foundation.h>
@class File;

/**
 *  Represents a Photo.
 */
@interface BCPSPhoto : NSObject

// Caption of the photo.
@property (nonatomic, copy) NSString *caption;

// Photo Identification.
@property (nonatomic, copy) NSString *uuid;

// Reference to the file where the photo is stored.
@property (nonatomic, strong) File *photoFile;

// Indicates whether the meta file has been modified.
@property (nonatomic, assign) BOOL metaFileModified;

// Users who has liked this photo.
@property (nonatomic, strong) NSMutableArray *likedUsers;

// Indicates whether this photos is shared.
@property (nonatomic, assign) BOOL isShared;

// Username of the user who uploaded this photo.
@property (nonatomic, copy) NSString *username;

// Shared photo time in GMT.
@property (assign) NSTimeInterval sharedTime;

// Reference to local file location where the file is stored.
@property (nonatomic, strong) NSURL *fileURL;

/**
 *  Initializes BCPSPhoto from given dictionary.
 *
 *  @param dictionary The dictionary containing values to be set.
 *
 *  @return An initialized BCPSPhoto object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/**
 *  Initializes BCPSPhoto from given JSON formatted string.
 *
 *  @param json A string in JSON format.
 *
 *  @return An initialized BCPSPhoto object.
 */
- (instancetype)initWithJSON:(NSString *)json;

/**
 *  Returns JSON Representation of the defined properties.
 *
 *  @return A string in JSON format.
 */
@property (nonatomic, readonly, copy) NSString *JSONRepresentation;

/**
 *  Return a Dictionary of defined properties.
 *
 *  @return a dictionary of this object.
 */
- (NSDictionary *)dictionaryRepresentation;

@end
