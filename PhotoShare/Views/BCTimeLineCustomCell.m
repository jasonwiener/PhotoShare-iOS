//
//  BCTimeLineCustomCell.m
//  PhotoShare
//
//  Created by Chathurka on 10/24/14.
//
//

#import "BCTimeLineCustomCell.h"
#import "BCPhotoShareService.h"
#import "BCPSPhoto.h"

@implementation BCTimeLineCustomCell
{
    UIImageView *_imageView;
    __weak UITableView *_tableView;
    UIActivityIndicatorView *_activityIndicator;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                withTableView:(UITableView *)tableView
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _tableView = tableView;
        
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.5f);
        topBorder.backgroundColor = [UIColor darkGrayColor].CGColor;
        [self.contentView.layer addSublayer:topBorder];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 330.0f )];
        _imageView.backgroundColor  = [UIColor lightGrayColor];
        _imageView.contentMode = UIViewContentModeScaleToFill;

        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.center = _imageView.center;

        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_activityIndicator];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)startPhotoDownloading
{
    _imageView.image = nil;
    [_activityIndicator startAnimating];
    
    [_photoService retrievePhotoFileFromPhotoDetails:_photo withCompletion:^(BCPSPhoto *photoDetails, NSURL *fileURL) {
         dispatch_async(dispatch_get_main_queue(), ^{
             _imageView.image = [UIImage imageWithContentsOfFile:fileURL.path];
             [_activityIndicator stopAnimating];
         });
    }];
}

@end
