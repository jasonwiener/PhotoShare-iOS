//
//  UIbuttonEventTracking.h
//  PhotoShare
//
//  Created by Chathurka on 10/24/14.
//
//

#import <Foundation/Foundation.h>
/**
 *  Identifing Button event tracking
 */
@protocol BCUIButtonEventTracking <NSObject>
@optional
/**
 * Fire event if user click follow or unfollow button.
 *
 *  @param state follow or unfollow.
 *  @param row   selected row.
 */
- (void)didSelectFriendFollowButton:(BOOL)state withRow:(NSInteger)row;

/**
 *  Fire event if user click like button.
 *
 *  @param state   like or unlike.
 *  @param section selected section.
 */
- (void)didSelectTimeLineLikeButton:(BOOL)state withSection:(NSInteger)section;

/**
 *  Fire event if user click delete button.
 *
 *  @param section selected section.
 */
- (void)didSelectTimeLineDeleteButtonWithSection:(NSInteger)section;

/**
 *  Fire event when clicking share button.
 *
 *  @param state   Private or Public share.
 *  @param section selected section
 */
- (void)didSelectMyPhotoShareButton:(BOOL)state withSection:(NSInteger)section;

/**
 *  Fire Event if sign up button is clicked.
 *
 *  @param username createdUsername.
 *  @param password password.
 */
- (void)didSelectSignUpButtonWithUsername:(NSString *)username password:(NSString *)password;

@end
