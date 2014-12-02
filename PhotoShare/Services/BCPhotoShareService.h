//
//  BCPhotoShareService.h
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/17/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

@class BCPSPhoto;
@class BCFolderService;
@class BCCredentialsService;
@class BCFileTransferService;
@class BCUserService;
@class File;

/**
 *  Provides an interface to create, read, delete and share Photos.
 */
@interface BCPhotoShareService : NSObject

/**
 *  Initializes BCPhotoShareService with given Credential Service and Folder Service.
 *
 *  @param credentialsService   Credential Service instance.
 *  @param folderService        Folder Service instance.
 *  @param fileTrasnferService  File Trasnfer Service instance.
 *  @param userService          User Service instance.
 *
 *  @return Returns an initialized BCPhotoShareService instance.
 */
- (instancetype)initWithCredentialsService:(BCCredentialsService *)credentialsService
                          andFolderService:(BCFolderService *)folderService
                    andFileTransferService:(BCFileTransferService *)fileTransferService
                            andUserService:(BCUserService *)userService NS_DESIGNATED_INITIALIZER;

/**
 *  Retrieves photo meta for the main timeline which includes all the photos of current user and friends photos.
 *
 *  @param handler Executes upon completion with Photo details array.
 */
- (void)retrievePhotoDetailsWithCompletion:(void (^)(BOOL success, NSArray *bcpsPhotos))handler;

/**
 *  Retrieves photo meta for the history timeline which includes only the photos of current user.
 *
 *  @param username username.
 *  @param handler  Executes upon completion with Photo details array.
 */
- (void)retrievePhotoDetailsOfCurrentUserWithCompletion:(void (^)(NSMutableArray *bcpsPhotos))handler;

/**
 *  Uploads the Photo Details and notifies on completion.
 *
 *  @param photo A BCPSPhoto containing the Photo details to be uploaded.
 *  @param handler  Completion handler which executes upon success or failure.
 */
- (void)uploadPhotoDetails:(BCPSPhoto *)photo completion:(void (^)(BOOL success))handler;

/**
 *  Uploads the Photo Details along with actual photo file and notifies on completion.
 *
 *  @param photo   A BCPSPhoto containing the Photo details to be uploaded.
 *  @param fileURL A NSURL object with the reference to photo file.
 *  @param handler Completion handler which executes upon success or failure.
 */
- (void)uploadPhotoDetails:(BCPSPhoto *)photo andFile:(NSURL *)fileURL withCompletion:(void (^)(BOOL success))handler;

/**
 *  Retrieves actual image from Bitcasa and executes the completion block with downloaded location.
 *
 *  @param photoDetails The BCPSPhoto object which contains details about the photo to be downloaded.
 *  @param handler      Completion handler which exectutes upon success or failure with BCPSPhoto object and the download location.
 */
- (void)retrievePhotoFileFromPhotoDetails:(BCPSPhoto *)photoDetails withCompletion:(void (^)(BCPSPhoto *photoDetails, NSURL *fileURL))handler;

/**
 *  Deletes a Photo.
 *
 *  @param photo Photo to be deleted.
 *  @param handler Completion handler which executes upon success or failure of the deletion.
 */
- (void)deletePhoto:(BCPSPhoto *)photo withCompletion:(void (^)(BCPSPhoto *item, BOOL success))handler;

/**
 *  Update the Photo Details with change the share state of photo.
 *
 *  @param photo       A BCPSPhoto containing the Photo details to be uploaded.
 *  @param sharedState Whether photo is public or private.
 *  @param handler     Completion handler which executes upon success or failure.
 */
- (void)uploadPhotoDetails:(BCPSPhoto *)photo andSharedState:(BOOL)sharedState completion:(void (^)(BOOL))handler;

/**
 *  Deletes all the photos of the given user.
 *
 *  @param username The username of the user whose photos needs to be deleted.
 *  @param handler  Completion handler which executes upon success or failure.
 */
- (void)deletePhotosOfUser:(NSString *)username withCompletion:(void (^)(BOOL success))handler;

@end
