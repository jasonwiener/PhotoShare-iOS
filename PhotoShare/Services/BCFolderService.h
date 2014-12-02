//
//  BCFolderService.h
//  PhotoShare
//
//  Created by Nalinda Somasundara on 11/2/14.
//
//

#import <Foundation/Foundation.h>
#import "BCCredentialsService.h"

/**
 *  Initializes or creates required folder structures for PhotoShare app
 *  on device and Bitcasa accounts (User and App).
 */
@interface BCFolderService : NSObject

#pragma mark - Folder reference properties of App Account.
// Reference to the Photo Share Users folder on the device.
@property (readonly) NSURL *appUsersLocalFolder;

// Reference to the users folder on Bitcasa of the App account.
@property (readonly) Folder *appUsersRemoteFolder;

// Reference to the Photo Share Meta file on the device.
@property (readonly) NSURL *appMetaLocalFile;
// Reference to the Photo Share Meta file of the App account on Bitcasa.
@property (nonatomic, strong) File *appMetaRemoteFile;

// Reference to the Photo Share App account folder on the device.
@property (readonly) NSURL *appLocalFolder;

// Reference to the Photo Share App account folder of the App account on Bitcasa.
@property (readonly) Folder *appRemoteFolder;

#pragma mark - Folder reference properties of User.
// Reference to the Photo Share Private folder on the device.
@property (readonly) NSURL *privateLocalFolder;

// Reference to the Photo Share Private folder  of the User account on Bitcasa.
@property (readonly) Folder *privateRemoteFolder;

// Reference to the Photo Share Public folder on the device.
@property (readonly) NSURL *publicLocalFolder;

// Reference to the Photo Share Public folder of the User account on Bitcasa.
@property (readonly) Folder *publicRemoteFolder;

// Reference to the Photo Share folder of the User account on Bitcasa.
@property (readonly) Folder *photoShareRemoteFolder;

// Reference to the Photo Share folder of the User account on the device.
@property (readonly) NSURL *photoShareLocalFolder;

// Reference to the Shared folder of the User account on Bitcasa.
@property (readonly) Folder *sharedRemoteFolder;

// Reference to the Shared folder of the User account on the device.
@property (readonly) NSURL *sharedLocalFolder;

// The share key of the public folder.
@property (nonatomic, copy) NSString *shareKey;

/**
 *  Intializes an instance of the BCFolderService.
 *  This is the designated initalizer for this class.
 *
 *  @param credentialsService An instance of BCCredentialsService class.
 *
 *  @return An initialized instance of BCFolderService.
 */
- (instancetype)initWithCredentialsService:(BCCredentialsService *)credentialsService NS_DESIGNATED_INITIALIZER;

/**
 *  Sets the folder and file property references of this object related to App Account.
 *  If any of the folders are not found on device or on Bitcasa, they are created before setting the references.
 *
 *  @param completion Completion handler which gets executed upon success or failure with the status.
 */
- (void)initializeAppFolderStructureWithCompletion:(void (^)(BOOL success))completion;

/**
 *  Sets the private folder and file property references of this object related to User.
 *  If any of the folders are not found on device or on Bitcasa, they are created before setting the references.
 *
 *  @param completion Completion handler which gets executed upon success or failure with the status.
 */
- (void)initializePrivateFolderStructureWithCompletion:(void (^)(BOOL success))completion;

/**
 *  Sets the public folder and file property references of this object related to User.
 *  If any of the folders are not found on device or on Bitcasa, they are created before setting the references.
 *
 *  @param completion Completion handler which gets executed upon success or failure with the status, shareKey and publicFolderPath.
 */
- (void)initializePublicFolderStructureWithCompletion:(void (^)(BOOL success, NSString *shareKey, NSString *publicFolderPath))completion;

/**
 *  Sets the shared folder references of this object related to the User.
 *  If any of the folders are not found on device or on Bitcasa, they are created before setting the references.
 *
 *  @param completion Completion handler which gets executed upon success or failure with the status.
 */
- (void)initializeSharedFolderStructureWithCompletion:(void (^)(BOOL success))completion;

/**
 *  Gets the Bitcasa Folder reference for the Shared Folder of the User.
 *
 *  @param username   The username of the User which the Shared Folder should be returned.
 *  @param completion Completion handler which gets executed upon success or failure with the Folder reference.
 */
- (void)getSharedRemoteFolderOfUsername:(NSString *)username withCompletion:(void (^)(Folder *sharedFolder))completion;

/**
 *  Initialiazed App meta file if it's not available or mismatch with current file.
 *
 *  @param completion Completion handler which gets executed upon success or failure with the status.
 */
- (void)initializeMetaFileWithCompletion:(void(^)(BOOL success))completion;

@end
