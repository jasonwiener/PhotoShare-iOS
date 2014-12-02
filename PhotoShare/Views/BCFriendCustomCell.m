//
//  BCFriendCustomCell.m
//  PhotoShare
//
//  Created by Chathurka on 10/24/14.
//
//

#import "BCFriendCustomCell.h"
#import "BCUIButtonEventTracking.h"

#define FOLLOW_BUTTON_X 320
#define FOLLOW_BUTTON_Y 10
#define FOLLOW_BUTTON_WIDTH 80.0f
#define FOLLOW_BUTTON_HIGHT 28.0f

#define FOLLOW 100
#define UNFOLLOW 101

@implementation BCFriendCustomCell
{
    UITableView *_tableView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTableView:(UITableView *)tableView;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        _tableView = tableView;

        self.followButton = [[UIButton alloc] initWithFrame:CGRectMake(_tableView.bounds.size.width - 85.0f, 10.0f, FOLLOW_BUTTON_WIDTH, FOLLOW_BUTTON_HIGHT)];
        self.followButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        self.followButton.layer.borderWidth = 1.0f;
        self.followButton.layer.cornerRadius = 6.0f;
        [self.followButton addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.followButton];
    }
    
    return self;
}

- (void)followAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectFriendFollowButton:withRow:)])
    {
        BOOL state = !(self.followButton.tag == FOLLOW);
        
        [self.delegate didSelectFriendFollowButton:state withRow:_row];
    }
}

- (void)setFollow:(BOOL)state
{
    if (state)
    {
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        [self.followButton  setTitleColor:[UIColor colorWithRed:35.0f/255.0f green:130.0f/255.0f blue:180.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
        self.followButton .layer.borderColor=[[UIColor colorWithRed:35.0f/255.0f green:130.0f/255.0f blue:180.0f/255.0f alpha:1.0] CGColor];
        self.followButton.tag = FOLLOW;
    }
    else
    {
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        self.followButton.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        [self.followButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.followButton.tag = UNFOLLOW;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x ,
                                      self.textLabel.frame.origin.y,
                                      self.textLabel.frame.size.width - 80.0f,
                                      self.textLabel.frame.size.height);
}

@end
