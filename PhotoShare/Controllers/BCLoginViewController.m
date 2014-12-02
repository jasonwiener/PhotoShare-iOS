//
//  BCLoginViewController.m
//  PhotoShare
//
//  Created by Chathurka on 10/22/14.
//
//

#import "BCLoginViewController.h"
#import "BCHomeViewController.h"
#import "BCFriendsViewController.h"
#import "BCHistoryViewController.h"
#import "BCLoginViewController.h"
#import "BCTabBarViewController.h"
#import "BCUserService.h"
#import "BCCredentialsService.h"
#import "BCFolderService.h"
#import "BCSignUpViewController.h"

@implementation BCLoginViewController
{
    BCTabBarViewController *_tabBarController;
    BCUserService *_userService;
    BCCredentialsService *_credentialsService;
    BCFolderService *_folderService;
    BCFileTransferService *_fileTransferService;
    BCPhotoShareService *_photoShareService;
}

- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(NSBundle *)nibBundle
              credentialsService:(BCCredentialsService *)credentialsService
                  folderService:(BCFolderService *)folderService
            fileTrasnferService:(BCFileTransferService *)fileTransferService
                    userService:(BCUserService *)userService
              photoShareService:(BCPhotoShareService *)photoShareService
{
    self = [super initWithNibName:nibName bundle:nil];
    
    if (self)
    {
        _credentialsService = credentialsService;
        _folderService = folderService;
        _fileTransferService = fileTransferService;
        _userService = userService;
        _photoShareService = photoShareService;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userName.delegate = self;
    self.password.delegate = self;
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods
- (IBAction)signIn:(UIButton *)sender
{
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    
    if (_userName.text.length > 0 && _password.text.length > 0)
    {
        [_credentialsService signInWithUsername:_userName.text
                                    andPassword:_password.text
                                     completion:^(BOOL success)
         {
             if (success)
             {
                 _userName.text = @"";
                 _password.text = @"";
                
                 [self navigateToHome];
             }
             else
             {
                 [self showalertWithMessage:@"Login Error."];
             }
         }];
    }
    else
    {
        [self showalertWithMessage:@"Empty username or password."];
    }
}

- (IBAction)signUp:(UIButton *)sender
{
    BCSignUpViewController *signUpviewController = [[BCSignUpViewController alloc] initWithNibName:@"BCSignUpViewController"
                                                                                            bundle:nil
                                                                                 credentialService:_credentialsService];
    signUpviewController.buttonDelegate = self;
    
    UINavigationController *presentNavigationController = [[UINavigationController alloc] initWithRootViewController:signUpviewController];
    [self presentViewController:presentNavigationController animated:YES completion:nil];
}

/**
 *  Navigate to Home
 */
- (void)navigateToHome
{
    _tabBarController = [[BCTabBarViewController alloc] initWithUserService:_userService
                                                              folderService:_folderService
                                                          photoShareService:_photoShareService
                                                         credentialsService:_credentialsService
                                                        fileTrasnferService:_fileTransferService];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:_tabBarController animated:YES];
}

/**
 *  Shows the alert according to given message.
 *
 *  @param message The message to show.
 */
- (void)showalertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PhotoShare"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder)
    {
        [nextResponder becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self performSelector:@selector(signIn:)withObject:nil];
    }
    
    return NO;
}

#pragma mark - BCUIButtonEventTracking

- (void)didSelectSignUpButtonWithUsername:(NSString *)username password:(NSString *)password
{
    _userName.text = username;
    _password.text = password;
    
    [self signIn:nil];
}

@end
