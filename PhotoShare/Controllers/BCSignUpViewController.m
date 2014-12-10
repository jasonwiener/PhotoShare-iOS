//
//  BCSignUpViewController.m
//  PhotoShare
//
//  Created by Chathurka on 11/18/14.
//
//

#import "BCSignUpViewController.h"
#import "BCUIButtonEventTracking.h"

@implementation BCSignUpViewController
{
    UIActivityIndicatorView *_activityIndicator;
    BCCredentialsService *_credentialsService;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
              credentialService:(BCCredentialsService *)creadentialService
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        _credentialsService = creadentialService;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.username.delegate = self;
    self.password.delegate = self;
    self.firstName.delegate = self;
    self.lastName.delegate = self;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.backgroundColor = [UIColor whiteColor];
    _activityIndicator.hidden = YES;
    
    [self.view addSubview:_activityIndicator];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Register"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(signUp:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)cancel:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUp:(UIButton *)sender
{
    _activityIndicator.center = self.view.center;
    [_activityIndicator startAnimating];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [_credentialsService signUpWithUsername:self.username.text
                                   password:self.password.text
                                  firstName:self.firstName.text
                                   lastName:self.lastName.text
                                 completion:^(BOOL success) {
                                     
                                     if(success) {
                                         [self.buttonDelegate didSelectSignUpButtonWithUsername:self.username.text password:self.password.text];
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                         
                                     } else {
                                         [self showAlertWithMessage:@"Registration Error."];
                                     }
                                     
                                     [_activityIndicator stopAnimating];
                                     self.navigationItem.leftBarButtonItem.enabled = YES;
                                     self.navigationItem.rightBarButtonItem.enabled = YES;
                                 }];
}

- (void)showAlertWithMessage:(NSString *)message
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
        [self performSelector:@selector(signUp:)withObject:nil];
    }
    
    return NO;
}

@end
