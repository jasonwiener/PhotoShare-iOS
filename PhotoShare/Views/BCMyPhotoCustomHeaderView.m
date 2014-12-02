//
//  BCMyPhotoCustomHeaderView.m
//  PhotoShare
//
//  Created by Chathurka on 10/28/14.
//
//

#import "BCMyPhotoCustomHeaderView.h"

@implementation BCMyPhotoCustomHeaderView
{
    UITableView *_tableView;
    UILabel *_sharedPhotoCaption;
    UILabel *_sharePhotoDate;
}

- (instancetype)initWithTaleView:(UITableView *)tableView
                         caption:(NSString *)caption
                      sharedTime:(NSTimeInterval )sharedTime
{
    if (self = [super init])
    {
        _tableView = tableView;
        
        [self setFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 26.0f)];
        
        UIFont *captionFont = [UIFont fontWithName:@"Helvetica" size:12.0f];
        UIFont *timeFont = [UIFont fontWithName:@"Helvetica" size:9.0f];
        
        _sharedPhotoCaption = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, _tableView.bounds.size.width, 9.0f)];
        _sharedPhotoCaption.textColor = [UIColor darkGrayColor];
        _sharedPhotoCaption.font = captionFont;
        _sharedPhotoCaption.text = caption;
        
        _sharePhotoDate = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 16.0f, _tableView.bounds.size.width - 10.0f, 9.0f)];
        _sharePhotoDate.textColor = [UIColor darkGrayColor];
        _sharePhotoDate.font = timeFont;
        _sharePhotoDate.textAlignment = NSTextAlignmentRight;
        _sharePhotoDate.text = [self dateStringFromTimeInterval:sharedTime];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 26.0f)];
        background.alpha = 0.6f;
        background.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:background];
        [self addSubview:_sharedPhotoCaption];
        [self addSubview:_sharePhotoDate];
    }
    
    return self;
}

- (NSString *)dateStringFromTimeInterval:(NSTimeInterval)timeInterval
{
    NSMutableString *dateString = [NSMutableString string];
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateString appendString:[formatter stringFromDate:currentDate]];
    
    [formatter setDateFormat:@"HH:mm"];
    [dateString appendString:@" "];
    [dateString appendString:[formatter stringFromDate:currentDate]];
    
    return dateString;
}

@end
