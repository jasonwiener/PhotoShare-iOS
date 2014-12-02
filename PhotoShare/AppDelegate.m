//
//  AppDelegate.m
//  PhotoShare
//
//  Created by Chathurka on 10/22/14.
//
//

#import "AppDelegate.h"
#import "BCHomeViewController.h"
#import "BCLoginViewController.h"
#import "BCTabBarViewController.h"
#import "BCUserService.h"
#import "BCCredentialsService.h"
#import "BCFolderService.h"
#import "BCPSUser.h"
#import "BCPhotoShareService.h"
#import "BCFileTransferService.h"

@implementation AppDelegate
{
    BCUserService *_userService;
    BCCredentialsService *_credentialsService;
    BCFolderService *_folderService;
    BCPhotoShareService *_photoShareService;
    BCFileTransferService *_fileTrasnferService;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _credentialsService = [[BCCredentialsService alloc] init];
    _folderService = [[BCFolderService alloc] initWithCredentialsService:_credentialsService];
    _fileTrasnferService = [[BCFileTransferService alloc] init];
    _userService = [[BCUserService alloc] initWithCredentialsService:_credentialsService
                                                    andFolderService:_folderService andFileTransferService:_fileTrasnferService];

    
    _photoShareService = [[BCPhotoShareService alloc] initWithCredentialsService:_credentialsService
                                                                andFolderService:_folderService
                                                          andFileTransferService:_fileTrasnferService
                                                                  andUserService:_userService];
    
    if ([_credentialsService isAuthenticated])
    {
        [self setupTabBarViewController];
    }
    else
    {
        BCLoginViewController *loginController = [[BCLoginViewController alloc] initWithNibName:@"BCLoginViewController"
                                                                                         bundle:nil
                                                                             credentialsService:_credentialsService
                                                                                  folderService:_folderService
                                                                            fileTrasnferService:_fileTrasnferService
                                                                                    userService:_userService
                                                                              photoShareService:_photoShareService];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
        
        [self.window addSubview:navigationController.view];
        self.window.rootViewController = navigationController;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)setupTabBarViewController
{
    self.tabBarController = [[BCTabBarViewController alloc] initWithUserService:_userService
                                                                  folderService:_folderService
                                                              photoShareService:_photoShareService
                                                             credentialsService:_credentialsService
                                                            fileTrasnferService:_fileTrasnferService];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    
    [self.window addSubview:self.tabBarController.view];
    self.window.rootViewController = navigationController;
}

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return ![viewController isEqual:[aTabBarController viewControllers][1]];
}

@end
