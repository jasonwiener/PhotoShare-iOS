//
//  BCTimeLineCustomHeaderView.h
//  PhotoShare
//
//  Created by Chathurka on 10/27/14.
//
//

#import <UIKit/UIKit.h>

@interface BCTimeLineCustomHeaderView : UIView
/**
 *  Initialized CustomTimelineHeader object with following parameters.
 *
 *  @param tableView Time line table view.
 *  @param username   Who is owned this photo.
 *  @param caption    Description of Photo.
 *  @param sharedTime Shared photo date and time.
 *
 *  @return Return header view.
 */
- (instancetype)initWithTaleView:(UITableView *)tableView
                        username:(NSString *)username
                         caption:(NSString *)caption
                      sharedTime:(NSTimeInterval )sharedTime NS_DESIGNATED_INITIALIZER;

@end
