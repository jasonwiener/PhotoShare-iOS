//
//  BCSignUpViewController.h
//  PhotoShare
//
//  Created by Chathurka on 11/18/14.
//
//

#import <UIKit/UIKit.h>
#import "BCCredentialsService.h"

@protocol BCUIButtonEventTracking;

@interface BCSignUpViewController : UIViewController <UITextFieldDelegate>

// username Textfeild.
@property (strong, nonatomic) IBOutlet UITextField *username;
//password Textfeild.
@property (strong, nonatomic) IBOutlet UITextField *password;
//first name Textfeild.
@property (strong, nonatomic) IBOutlet UITextField *firstName;
//last name Textfeild.
@property (strong, nonatomic) IBOutlet UITextField *lastName;
// Button delegate for sign up Button event.
@property (weak, nonatomic) NSObject<BCUIButtonEventTracking> *buttonDelegate;

/**
 *  Class init with following parameters.
 *
 *  @param nibName             Nib file name.
 *  @param nibBundle           Bundle.
 *  @param credentialsService  credential service.
 *
 *  @return  Return class object with above parameters.
 */
- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
              credentialService:(BCCredentialsService *)creadentialService NS_DESIGNATED_INITIALIZER;

@end
