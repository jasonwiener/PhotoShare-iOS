//
//  BCPhotoPresentViewController.m
//  PhotoShare
//
//  Created by Chathurka on 10/27/14.
//
//

#import "BCPhotoPresentViewController.h"
#import "BCPSPhoto.h"
#import "BCPhotoShareService.h"
#import "BCUserService.h"
#import "BCPSUser.h"

@implementation BCPhotoPresentViewController
{
    UITextField *_imageCaption;
    UIImageView *_imageView;
    UIScrollView *_scrollView;
    UISwitch *_shareSwitch;
    UILabel *_shareSwitchLabel;
    BOOL _photoShareState;
    UIActivityIndicatorView *_activityIndicator;
}

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageCaption = [[UITextField alloc] init];
        _imageCaption.delegate = self;
        _imageCaption.placeholder = @"Enter Caption";
        _shareSwitch = [[UISwitch alloc] init];
        _shareSwitchLabel = [[UILabel alloc] init];
        _shareSwitchLabel.text = @"Sharing";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    self.view = _scrollView;
    
    [_shareSwitch addTarget:self action:@selector(changeSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    _activityIndicator.hidesWhenStopped = YES;
    
    [_scrollView addSubview:_imageView];
    [_scrollView addSubview:_shareSwitchLabel];
    [_scrollView addSubview:_shareSwitch];
    [_scrollView addSubview:_imageCaption];
    [_scrollView addSubview:_activityIndicator];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(share:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _imageView.frame = CGRectMake(0, 5.0f, self.view.frame.size.width, 280.0f);
    _shareSwitchLabel.frame = CGRectMake(10.0f, _imageView.frame.size.height + 10.0f, 150.0f , 30.0f);
    _shareSwitch.frame = CGRectMake(_scrollView.frame.size.width - 60.0f, _imageView.frame.size.height + 10.0f, 50.0f , 30.0f);
    _imageCaption.frame = CGRectMake(10.0f, _shareSwitchLabel.frame.origin.y + _shareSwitchLabel.frame.size.height + 10.0f, _scrollView.frame.size.width - 10.0f , 30.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods.

- (void)enableObjects
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _imageCaption.enabled = YES;
    
    [_activityIndicator stopAnimating];
}

- (void)disableObjects
{
    [_activityIndicator startAnimating];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    _imageCaption.enabled = NO;
}

- (void)saveImage: (UIImage*)image withURL:(NSURL *)url
{
    NSData* data = UIImagePNGRepresentation(image);
    [data writeToFile:url.path atomically:YES];
}

- (void)removelastCapturedImageWithURL:(NSURL *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if ([fileManager fileExistsAtPath:url.path] &&
        [fileManager isDeletableFileAtPath:url.path] &&
        [fileManager removeItemAtPath:url.path error:&error])
    {
        NSLog(@"Deleted last captured image.");
    }
    else
    {
        NSLog(@"Error occured while deleting - %@.",error);
    }
}

#pragma mark - Switch Event.

- (void)changeSwitchAction:(UISwitch *)sender
{
    _photoShareState = sender.on;
}

- (void)cancel:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)share:(UIButton *)sender
{
    NSURL *capturedImageURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"capturedImage.png"] isDirectory:NO];
    
    [self removelastCapturedImageWithURL:capturedImageURL];
    [self saveImage:_imageView.image withURL:capturedImageURL];
    
    BCPSPhoto *uploadTimeLinePhoto = [[BCPSPhoto alloc] init];
    uploadTimeLinePhoto.caption = _imageCaption.text;
    uploadTimeLinePhoto.username = self.userService.currentUser.username;
    uploadTimeLinePhoto.isShared = _photoShareState;
    uploadTimeLinePhoto.sharedTime = [[NSDate date] timeIntervalSince1970];
    
    [self disableObjects];
    
    [self.photoShareService uploadPhotoDetails:uploadTimeLinePhoto andFile:capturedImageURL withCompletion:^(BOOL success) {
        [self enableObjects];
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTimeLine" object:nil];
    }];
}

#pragma mark NSNotificationCenter event.

- (void)keyboardWillShow:(NSNotification*)note
{
    CGRect keyboardFrameEnd = [(note.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = _scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [_scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = _scrollView.contentOffset;
    scrollViewContentOffset.y += keyboardFrameEnd.size.height;
    scrollViewContentOffset.y -= 100.0f;
    [_scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGRect keyboardFrameEnd = [(note.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = _scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [_scrollView setContentSize:scrollViewContentSize];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
