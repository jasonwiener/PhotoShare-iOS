//
//  BCTabBarViewController.m
//  PhotoShare
//
//  Created by Chathurka on 10/23/14.
//
//

#import "BCTabBarViewController.h"
#import "BCHomeViewController.h"
#import "BCFriendsViewController.h"
#import "BCHistoryViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "BCPhotoPresentViewController.h"
#import "BCPSUser.h"
#import "BCLoginViewController.h"

#define SETTING_ACTION_SHEET_TAG 100
#define TAKE_PHOTO_TAG 101

#define TABBAR_MY_PHOTO 3
#define TABBAR_FRIENDS 2

@implementation BCTabBarViewController
{
    UIActivityIndicatorView *_activityIndicator;
    UIView *_backGround;
    BCUserService *_userService;
    BCFolderService *_folderService;
    UIButton *_cameraButton;
    BCPhotoShareService *_photoShareService;
    BCCredentialsService *_credentialService;
    BCFileTransferService *_fileTransferService;
}

- (instancetype)initWithUserService:(BCUserService *)userService
                      folderService:(BCFolderService *)folderService
                  photoShareService:(BCPhotoShareService *)photoShareService
                 credentialsService:(BCCredentialsService *)credentialService
                fileTrasnferService:(BCFileTransferService *)fileTransferService
{
    if ( self = [super init])
    {
        _userService = userService;
        _folderService = folderService;
        _photoShareService = photoShareService;
        _credentialService = credentialService;
        _fileTransferService = fileTransferService;
        
        self.navigationItem.hidesBackButton = YES;
        self.tabBar.barTintColor = [UIColor colorWithRed:0.0f/255.0f green:10.0f/255.0f blue:15.0f/255.0f alpha:1.0f]; // tab bar color
        self.tabBar.tintColor = [UIColor whiteColor]; //selected tab bar color
        
        [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"TabBarSelected"]];
        
        UIColor *titleColor = [UIColor colorWithRed:35.0f/255.0f green:130.0f/255.0f blue:180.0f/255.0f alpha:1.0];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:titleColor}];
    }
    
    return self;
}

- (void)setupTabBar
{
    BCHomeViewController *homeController = [[BCHomeViewController alloc] initWithNibName:@"BCHomeViewController"
                                                                                  bundle:nil
                                                                       photoShareService:_photoShareService
                                                                             userService:_userService];
    
    BCFriendsViewController *friendsController = [[BCFriendsViewController alloc] initWithNibName:@"BCFriendsViewController"
                                                                                           bundle:nil
                                                                                      userService:_userService];
    
    BCHistoryViewController *historyController = [[BCHistoryViewController alloc] initWithNibName:@"BCHistoryViewController"
                                                                                           bundle:nil
                                                                                photoShareService:_photoShareService
                                                                                      userService:_userService];
    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"TabBarHome"] tag:1];
    UITabBarItem *friendTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"TabBarFriends"] tag:3];
    UITabBarItem *historyTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"TabBarHistry"] tag:4];
    
    [homeController setTabBarItem:homeTabBarItem];
    [friendsController setTabBarItem:friendTabBarItem];
    [historyController setTabBarItem:historyTabBarItem];
    
    UINavigationController *homeNavigationViewController = [[UINavigationController alloc] initWithRootViewController:homeController];
    UINavigationController *emptyCameraNavigationController = [[UINavigationController alloc] init];
    UINavigationController *friendsNavigationViewController = [[UINavigationController alloc] initWithRootViewController:friendsController];
    UINavigationController *historyNavigationViewController = [[UINavigationController alloc] initWithRootViewController:historyController];
    
    self.viewControllers = @[homeNavigationViewController, emptyCameraNavigationController, friendsNavigationViewController, historyNavigationViewController];
}

- (void)setupActivityIndicator
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.center = self.view.center;
    _activityIndicator.backgroundColor = [UIColor whiteColor];
    _activityIndicator.hidden = YES;
    
    _backGround = [[UIView alloc] initWithFrame:self.view.frame];
    _backGround.backgroundColor = [UIColor whiteColor];
    _backGround.hidden = YES;
    
    [self.view addSubview:_backGround];
    [self.view addSubview:_activityIndicator];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupActivityIndicator];
    [self setupLeftProfileSetting];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self startAnimating];
    
    if (_userService.currentUser == nil)
    {
        [self createFolderStructure];
    }
}

#pragma mark - Private Methods

- (void)logout
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (!(viewControllers.count > 0 && [[viewControllers firstObject] isMemberOfClass:[BCLoginViewController class]]))
    {
        BCLoginViewController *loginController = [[BCLoginViewController alloc] initWithNibName:@"BCLoginViewController"
                                                                                         bundle:nil
                                                                              credentialsService:_credentialService
                                                                                  folderService:_folderService
                                                                            fileTrasnferService:_fileTransferService
                                                                                    userService:_userService
                                                                              photoShareService:_photoShareService];
        
        NSMutableArray *mutableViewControllers = [NSMutableArray arrayWithArray:viewControllers];
        [mutableViewControllers insertObject:loginController atIndex:0];
        [self.navigationController setViewControllers: mutableViewControllers];
    }
    
    _userService.currentUser = nil;
    [_credentialService clearAuthKey];
    _folderService.shareKey = @"";
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)removeAccount
{
    [_photoShareService deletePhotosOfUser:_userService.currentUser.username withCompletion:^(BOOL success) {
        if (success) {
            [_userService removeAccountWithCompletion:^(BOOL success) {
                [self logout];
            }];
        }
    }];
}

- (void)startAnimating
{
    if (_userService.currentUser == nil)
    {
        _activityIndicator.hidden = NO;
        _backGround.hidden = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        _cameraButton.enabled = NO;
        _cameraButton.userInteractionEnabled = NO;
        
        [_activityIndicator startAnimating];
    }
}

- (void)stopAnimating
{
    [_activityIndicator stopAnimating];
    
    _backGround.hidden = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _activityIndicator.hidden = YES;
    _cameraButton.enabled = YES;
    _cameraButton.userInteractionEnabled = YES;
}

- (void)createFolderStructure
{
    [_folderService initializeAppFolderStructureWithCompletion:^(BOOL success) {
        if (success) {
            [_folderService initializePrivateFolderStructureWithCompletion:^(BOOL privateFolderSuccess) {
                if (privateFolderSuccess) {
                    [_userService retrieveCurrentUser:^(BCPSUser *user) {
                        _folderService.shareKey = user.publicFolderSharedKey;
                        
                        [_folderService initializeSharedFolderStructureWithCompletion:^(BOOL success) {
                            [_folderService initializePublicFolderStructureWithCompletion:^(BOOL publicFolderSuccess, NSString *shareKey, NSString *publicFolderPath) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (user.publicFolderSharedKey.length)
                                    {
                                        [self setupTabBar];
                                        [self stopAnimating];
                                    }
                                    else
                                    {
                                        user.publicFolderSharedKey = shareKey;
                                        user.publicFolderPath = publicFolderPath;
                                        [_userService saveCurrentUserWithCompletion:^(BOOL saveUserState) {
                                            [self setupTabBar];
                                            [self stopAnimating];
                                        }];
                                    }
                                });
                            }];
                        }];
                    }];
                }
            }];
        }
    }];
}

- (void)setupLeftProfileSetting
{
    UIImage *settingsImage = [UIImage imageNamed:@"NavigationBarSetting"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:settingsImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showSettingAction:)];
}

- (void)showSettingAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"My Photos", @"Follow Friends", @"Log Out", @"Remove Account", nil];
    [actionSheet setTag:SETTING_ACTION_SHEET_TAG];
    [actionSheet showFromTabBar:self.tabBar];
}

- (void)takePhotoAction:(id)sender
{
    BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraAvailable && photoLibraryAvailable) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet setTag:TAKE_PHOTO_TAG];
        [actionSheet showFromTabBar:self.tabBar];
    }
}

- (BOOL)shouldStartCameraController
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
        [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage])
    {
        cameraUI.mediaTypes = @[(NSString *)kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
        {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
        else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    else
    {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}


- (BOOL)shouldStartPhotoLibraryPickerController
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO))
    {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage])
    {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = @[(NSString *) kUTTypeImage];
        
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
             && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage])
    {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = @[(NSString *) kUTTypeImage];
    }
    else
    {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    BCPhotoPresentViewController *photoViewerViewController  = [[BCPhotoPresentViewController alloc] initWithImage:image];
    photoViewerViewController.photoShareService = _photoShareService;
    photoViewerViewController.userService = _userService;
    
    UINavigationController *presentNavigationController = [[UINavigationController alloc] initWithRootViewController:photoViewerViewController];
    [self presentViewController:presentNavigationController animated:NO completion:nil];
}

#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [super setViewControllers:viewControllers animated:animated];
    
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraButton.frame = CGRectMake(self.view.frame.size.width /4, -5.0f, 80.0f, self.tabBar.frame.size.height);
    [_cameraButton setImage:[UIImage imageNamed:@"TabBarCamera"] forState:UIControlStateNormal];
    [_cameraButton addTarget:self action:@selector(takePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:_cameraButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == SETTING_ACTION_SHEET_TAG)
    {
        switch (buttonIndex)
        {
            case 0: self.selectedIndex = TABBAR_MY_PHOTO; break;
            case 1: self.selectedIndex = TABBAR_FRIENDS; break;
            case 2: [self logout]; break;
            case 3: [self removeAccount]; break;

            default:
                break;
        }
    }
    else if (actionSheet.tag == TAKE_PHOTO_TAG)
    {
        switch (buttonIndex)
        {
            case 0:  [self shouldStartCameraController]; break;
            case 1:  [self shouldStartPhotoLibraryPickerController]; break;
                
            default:
                break;
        }
    }
}

@end
