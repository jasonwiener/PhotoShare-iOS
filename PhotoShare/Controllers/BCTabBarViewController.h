//
//  BCTabBarViewController.h
//  PhotoShare
//
//  Created by Chathurka on 10/23/14.
//
//

#import <UIKit/UIKit.h>
#import "BCUserService.h"
#import "BCFolderService.h"
#import "BCPhotoShareService.h"
#import "BCCredentialsService.h"

@interface BCTabBarViewController : UITabBarController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
/**
 *
 *
 *  @param userService       user service.
 *  @param folderService     folder service.
 *  @param photoShareService photo service.
 *  @param credentialService credential service.
 *  @param fileTransferService File Transfer Service.
 *
 *  @return return class object with above variables.
 */
- (instancetype)initWithUserService:(BCUserService *)userService
                      folderService:(BCFolderService *)folderService
                  photoShareService:(BCPhotoShareService *)photoShareService
                 credentialsService:(BCCredentialsService *)credentialService
                fileTrasnferService:(BCFileTransferService *)fileTransferService NS_DESIGNATED_INITIALIZER;

@end
