//
//  BCTimeLineCustomFooterView.m
//  PhotoShare
//
//  Created by Chathurka on 10/27/14.
//
//

#import "BCTimeLineCustomFooterView.h"

#define BUTTON_LIKE 100
#define BUTTON_UNLIKE 101

@implementation BCTimeLineCustomFooterView
{
    UILabel *_photolikeCountLabal;
    UITableView *_tableView;
    NSInteger _section;
    int _photoLikeCount;
    UIButton *_photoLikeButton;
}

-(instancetype)initWithTableView:(UITableView *)tableView
                         section:(NSInteger)section
                       likeCount:(int)likeCount
                            like:(BOOL)like
{
    self = [super init];
    
    if (self)
    {
        _tableView = tableView;
        _photoLikeCount = likeCount;
        _section = section;
        
        [self setFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 36.0f)];
        
        UIFont *shadowFont = [UIFont fontWithName:@"Helvetica" size:12.0f];
        _photolikeCountLabal = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.0f, 50.0f, 20.0f)];
        _photolikeCountLabal.font = shadowFont;
        _photolikeCountLabal.textColor = [UIColor darkGrayColor];
        
        _photoLikeButton = [[UIButton alloc] initWithFrame:CGRectMake(_tableView.bounds.size.width - 36.0f , 2.0f, 32.0f, 32.0f)];
        [_photoLikeButton addTarget:self action:@selector(likePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 36.0f)];
        background.alpha = 0.6f;
        background.backgroundColor = [UIColor whiteColor];
        
        if (like)
        {
            [_photoLikeButton setImage:[UIImage imageNamed:@"PhotoLike"] forState: UIControlStateNormal];
            _photolikeCountLabal.textColor = [UIColor colorWithRed:35.0f/255.0f green:130.0f/255.0f blue:180.0f/255.0f alpha:1.0];
            _photoLikeButton.tag = BUTTON_LIKE;
        }
        else
        {
            [_photoLikeButton setImage:[UIImage imageNamed:@"PhotoUnlike"] forState:UIControlStateNormal];
            _photolikeCountLabal.textColor = [UIColor darkGrayColor];
            _photoLikeButton.tag = BUTTON_UNLIKE;
        }
        
        [self setlikeCount:likeCount];
        [self addSubview:background];
        [self addSubview:_photolikeCountLabal];
        [self addSubview:_photoLikeButton];

    }
    
    return self;
}

- (void)likePhoto:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectTimeLineLikeButton:withSection:)])
    {
        BOOL likeState = (sender.tag == BUTTON_UNLIKE);
        [self.delegate didSelectTimeLineLikeButton:likeState withSection:_section];
    }
}

- (void)setLike:(BOOL)status
{
    if (status)
    {
        [_photoLikeButton setImage:[UIImage imageNamed:@"PhotoLike"] forState: UIControlStateNormal];
        _photoLikeButton.tag = BUTTON_LIKE;
        _photolikeCountLabal.textColor = [UIColor colorWithRed:35.0f/255.0f green:130.0f/255.0f blue:180.0f/255.0f alpha:1.0];
        _photoLikeCount++;
    }
    else
    {
        [_photoLikeButton setImage:[UIImage imageNamed:@"PhotoUnlike"] forState: UIControlStateNormal];
        _photoLikeButton.tag = BUTTON_UNLIKE;
        _photolikeCountLabal.textColor = [UIColor darkGrayColor];
        _photoLikeCount--;
    }
    
     _photolikeCountLabal.text = [NSString stringWithFormat:@"%i Likes",_photoLikeCount];
}


- (void)setlikeCount:(int)likeCount
{
    _photoLikeCount = likeCount;
     _photolikeCountLabal.text = [NSString stringWithFormat:@"%i Likes",_photoLikeCount];
}

@end
