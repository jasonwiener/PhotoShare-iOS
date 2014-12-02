//
//  BCFriendsViewController.h
//  PhotoShare
//
//  Created by Chathurka on 10/24/14.
//
//

#import <UIKit/UIKit.h>
#import "BCUIButtonEventTracking.h"

@class BCUserService;

@interface BCFriendsViewController : UITableViewController <UISearchBarDelegate, BCUIButtonEventTracking, UIGestureRecognizerDelegate,UIScrollViewDelegate>
/**
 *  Initialized Friend class with following parameters.
 *
 *  @param nibName     Nib file name.
 *  @param nibBundle   nib bundle.
 *  @param userService User service.
 *
 *  @return Return Friend class view controller.
 */
- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(NSBundle *)nibBundle
                    userService:(BCUserService *)userService NS_DESIGNATED_INITIALIZER;

@end
