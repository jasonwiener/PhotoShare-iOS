//
//  BCTimeLineCustomHeaderView.m
//  PhotoShare
//
//  Created by Chathurka on 10/27/14.
//
//

#import "BCTimeLineCustomHeaderView.h"

@implementation BCTimeLineCustomHeaderView
{
    UITableView *_tableView;
    UILabel *_username;
    UILabel *_caption;
    UILabel *_sharedTime;
}

- (instancetype)initWithTaleView:(UITableView *)tableView
                        username:(NSString *)username
                         caption:(NSString *)caption
                      sharedTime:(NSTimeInterval )sharedTime
{
    self = [super init];
    
    if (self)
    {
        _tableView = tableView;
        
        [self setFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 46.0f)];
        
        UIFont *boldFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
        UIFont *captionFont = [UIFont fontWithName:@"Helvetica" size:12.0f];
        UIFont *timeFont = [UIFont fontWithName:@"Helvetica" size:9.0f];
        
        _username = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.0f, _tableView.bounds.size.width, 16.0f)];
        _username.font = boldFont;
        _username.text = username;
        
        _caption = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 22.0f, _tableView.bounds.size.width, 9.0f)];
        _caption.textColor = [UIColor darkGrayColor];
        _caption.font = captionFont;
        _caption.text = caption;
        
        _sharedTime = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 33.0f, _tableView.bounds.size.width - 10.0f, 9.0f)];
        _sharedTime.textColor = [UIColor darkGrayColor];
        _sharedTime.font = timeFont;
        _sharedTime.textAlignment = NSTextAlignmentRight;
        _sharedTime.text = [self dateStringFromTimeInterval:sharedTime];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 46.0f)];
        background.alpha = 0.6f;
        background.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:background];
        [self addSubview:_username];
        [self addSubview:_caption];
        [self addSubview:_sharedTime];
        
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
