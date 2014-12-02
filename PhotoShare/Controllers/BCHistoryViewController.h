//
//  BCHistoryViewController.h
//  PhotoShare
//
//  Created by Chathurka on 10/27/14.
//
//

#import <UIKit/UIKit.h>
#import "BCUIButtonEventTracking.h"

@class BCPhotoShareService;
@class BCUserService;

@interface BCHistoryViewController : UITableViewController <BCUIButtonEventTracking, UIScrollViewDelegate>

/**
 *  Initialized Home view controller with following parameters.
 *
 *  @param nibName           Nib File name.
 *  @param nibBundle         Nib bundle.
 *  @param photoShareService Photo share service init from AppDelegate.
 *  @param userService       User service init from AppDelegate.
 *
 *  @return Return Home View Controller with following parameter.
 */
- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(NSBundle *)nibBundle
              photoShareService:(BCPhotoShareService *)photoShareService
                    userService:(BCUserService *)userService;

@end
