//
//  BCLoginViewController.h
//  PhotoShare
//
//  Created by Chathurka on 10/22/14.
//
//

#import <UIKit/UIKit.h>
#import "BCUIButtonEventTracking.h"

@class Session;
@class BCUserService;
@class BCCredentialsService;
@class BCFolderService;
@class BCPhotoShareService;
@class BCFileTransferService;

@interface BCLoginViewController : UIViewController <UITextFieldDelegate, BCUIButtonEventTracking>

/** Username Text feild. */
@property (weak, nonatomic) IBOutlet UITextField *userName;
/** Password Text feild. */
@property (weak, nonatomic) IBOutlet UITextField *password;

/**
 *  Class init with following parameters.
 *
 *  @param nibName             Nib file name.
 *  @param nibBundle           Bundle.
 *  @param credentialsService  credential service.
 *  @param folderService       Folder service.
 *  @param fileTransferService File Transfer Service.
 *  @param userService         User Service.
 *  @param photoShareService   Photo Share Service.
 *
 *  @return Return class object with above parameters.
 */
- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(NSBundle *)nibBundle
              credentialsService:(BCCredentialsService *)credentialsService
                  folderService:(BCFolderService *)folderService
            fileTrasnferService:(BCFileTransferService *)fileTransferService
                    userService:(BCUserService *)userService
              photoShareService:(BCPhotoShareService *)photoShareService NS_DESIGNATED_INITIALIZER;

/**
 *  User Sign in event.
 *
 *  @param sender owner of click event.
 */
- (IBAction)signIn:(UIButton *)sender;

- (IBAction)signUp:(UIButton *)sender;

@end
