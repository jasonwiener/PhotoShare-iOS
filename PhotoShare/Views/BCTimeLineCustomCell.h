//
//  BCTimeLineCustomCell.h
//  PhotoShare
//
//  Created by Chathurka on 10/24/14.
//
//

#import <UIKit/UIKit.h>

@class BCPhotoShareService;
@class BCPSPhoto;

@interface BCTimeLineCustomCell : UITableViewCell

//image  url for displaying
@property (nonatomic, strong) NSURL *imageUrl;
//Row number of Tablew view
@property (nonatomic ,assign) NSInteger section;
// Photo service
@property (nonatomic, strong) BCPhotoShareService *photoService;
//Assigned BCPSPhoto object maped with cell.
@property (nonatomic, strong) BCPSPhoto *photo;

/**
 *  Initialization Time line cell with 
 *
 *  @param style           <#style description#>
 *  @param reuseIdentifier <#reuseIdentifier description#>
 *  @param tableView       <#tableView description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                withTableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;

/**
 *  Start Photo downloading.
 */
- (void)startPhotoDownloading;

@end
