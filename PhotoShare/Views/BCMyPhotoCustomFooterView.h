//
//  BCMyPhotoCustomFooterView.h
//  PhotoShare
//
//  Created by Chathurka on 10/28/14.
//
//

#import <UIKit/UIKit.h>
#import "BCUIButtonEventTracking.h"

@interface BCMyPhotoCustomFooterView : UIView <BCUIButtonEventTracking, UIAlertViewDelegate>

// delegate object for button event tracking
@property (nonatomic, weak) NSObject<BCUIButtonEventTracking> *delegate;

/**
 *  Initalized Footer view with following parameters.
 *
 *  @param tableView My Photo tableview.
 *  @param section   Map with section of tableview.
 *  @param share     Share state of this photo.
 *
 *  @return Returns Footerview.
 */
- (instancetype)initWithTableView:(UITableView *)tableView
                          section:(NSInteger)section
                             share:(BOOL)share NS_DESIGNATED_INITIALIZER;

/**
 *  Set Share state of My photo tab.
 *
 *  @param status Whether photo is shared.
 */
- (void)setShare:(BOOL)status;

@end
