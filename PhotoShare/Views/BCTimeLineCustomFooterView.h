//
//  BCTimeLineCustomFooterView.h
//  PhotoShare
//
//  Created by Chathurka on 10/27/14.
//
//

#import <UIKit/UIKit.h>
#import "BCUIButtonEventTracking.h"

@interface BCTimeLineCustomFooterView : UIView <BCUIButtonEventTracking>

//button event tracking delegate
@property (nonatomic, weak) NSObject<BCUIButtonEventTracking> *delegate;

/**
 *  Initialized Timeline cell footer.
 *
 *  @param tableView Time line table view.
 *  @param section   Mape with section number with Tableview.
 *  @param likeCount How many likes for this.
 *  @param like      Whether current user is like.
 *
 *  @return Return timeline cell.
 */
- (instancetype)initWithTableView:(UITableView *)tableView
                          section:(NSInteger)section
                        likeCount:(int)likeCount
                             like:(BOOL)like NS_DESIGNATED_INITIALIZER;

/**
 *  Set like state Timeline footer view.
 *
 *  @param status state of the like.
 *
 */
- (void)setLike:(BOOL)status;

@end
