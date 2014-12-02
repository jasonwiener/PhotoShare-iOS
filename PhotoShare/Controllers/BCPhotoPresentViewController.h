//
//  BCPhotoPresentViewController.h
//  PhotoShare
//
//  Created by Chathurka on 10/27/14.
//
//

#import <UIKit/UIKit.h>

@class BCPhotoShareService;
@class BCUserService;

@interface BCPhotoPresentViewController : UIViewController <UITextFieldDelegate>

// photo share service
@property(nonatomic, strong) BCPhotoShareService *photoShareService;
// user service
@property(nonatomic, strong) BCUserService *userService;

/**
 *  Initialized with captured image.
 *
 *  @param image Captured image.
 *
 *  @return class object with image.
 */
- (instancetype)initWithImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;

@end
