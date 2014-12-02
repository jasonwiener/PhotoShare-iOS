//
//  BCUserService.h
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/28/14.
//
//

#import <Foundation/Foundation.h>
#import <BitcasaSDK/BitcasaAPI.h>

@class BCCredentialsService;
@class BCFolderService;
@class BCFileTransferService;
@class BCPSUser;

/**
 *  Provides an interface to manage user session and friends.
 */
@interface BCUserService : NSObject

// User object of currently signed in user.
@property (nonatomic, strong) BCPSUser *currentUser;

/**
 *  Initializes a BCUserService instance.
 *
 *  @param credentialsService  An instance of BCCredentialsService.
 *  @param folderService       An instance of BCFolderService.
 *  @param fileTransferService An instance of BCFileTransferService.
 *
 *  @return An initialized object of BCUserService.
 */
- (instancetype)initWithCredentialsService:(BCCredentialsService *)credentialsService
                          andFolderService:(BCFolderService *)folderService
                    andFileTransferService:(BCFileTransferService *)fileTransferService NS_DESIGNATED_INITIALIZER;

/**
 *  Saves data of the currently logged in user to Bitcasa.
 *
 *  @param completion Executes upon success or failure with the status.
 */
- (void)saveCurrentUserWithCompletion:(void (^)(BOOL))completion;

/**
 *  Retrieves the BCPSUser object of currently logged in user.
 *
 *  @param completion Executes with BCPSUser object when the retrieval is successful.
 */
- (void)retrieveCurrentUser:(void (^)(BCPSUser *user))completion;

/**
 *  Retrieve Users list
 *
 *  @param users names array.
 */
- (void)retrieveUserList:(void (^)(NSArray *userlist))completion;

/**
 *  Retrieves BCPSUser object from given username and caches the file.
 *
 *  @param username   The username of the user which needs to be retrieved.
 *  @param completion Handler which executed upon completion with BCPSUser object.
 */
- (void)retrieveUserByUsername:(NSString *)username completion:(void (^)(BCPSUser *user))completion;

/**
 *  Retrieves BCPSUser object from cache of given username.
 *
 *  @param username     The username of the user which needs to be retrieved.
 *  @param enableCache  Flags whether to use the cached user details.
 *  @param completion   Handler which executed upon completion with BCPSUser object.
 */
- (void)retrieveUserByUsername:(NSString *)username enableCache:(BOOL)enableCache completion:(void (^)(BCPSUser *user))completion;

/**
 *  Removes the user account details from Bitcasa and deletes local files.
 *
 *  @param completion Executes upon success or failure with the status.
 */
- (void)removeAccountWithCompletion:(void (^)(BOOL))completion;

@end
