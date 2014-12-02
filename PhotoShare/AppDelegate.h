//
//  AppDelegate.h
//  PhotoShare
//
//  Created by Chathurka on 10/22/14.
//
//

#import <UIKit/UIKit.h>

@class BCTabBarViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BCTabBarViewController *tabBarController;

@end

