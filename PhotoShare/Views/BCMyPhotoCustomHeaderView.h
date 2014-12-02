//
//  BCMyPhotoCustomHeaderView.h
//  PhotoShare
//
//  Created by Chathurka on 10/28/14.
//
//

#import <UIKit/UIKit.h>

@interface BCMyPhotoCustomHeaderView : UIView

/**
 *  Initialized CustomTimelineHeader object with following parameters.
 *
 *  @param tableView Time line table view.
 *  @param caption    Description of Photo.
 *  @param sharedTime Shared photo date.
 *
 *  @return Return header view.
 */
- (instancetype)initWithTaleView:(UITableView *)tableView
                         caption:(NSString *)caption
                      sharedTime:(NSTimeInterval )sharedTime NS_DESIGNATED_INITIALIZER;

@end
