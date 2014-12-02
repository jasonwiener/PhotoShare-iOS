//
//  BCFriendCustomCell.h
//  PhotoShare
//
//  Created by Chathurka on 10/24/14.
//
//

#import <UIKit/UIKit.h>
#import "BCUIButtonEventTracking.h"

@interface BCFriendCustomCell : UITableViewCell <BCUIButtonEventTracking>

//BC Button tracking delegate
@property (nonatomic, weak) NSObject <BCUIButtonEventTracking> *delegate;
//follow and unfollow button
@property (nonatomic ,strong) UIButton *followButton;
//Row number of Tablew view
@property (nonatomic ,assign) NSInteger row;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
                withTableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;
// Whether user is followed.
- (void)setFollow:(BOOL)state;

@end
