//
//  BCMyPhotoCustomFooterView.m
//  PhotoShare
//
//  Created by Chathurka on 10/28/14.
//
//

#import "BCMyPhotoCustomFooterView.h"

#define BUTTON_DELETE_YES_INDEX 1

@implementation BCMyPhotoCustomFooterView
{
    UITableView *_tableView;
    UIButton *_photoLikeButton;
    UIButton *_photoDeleteButton;
    UIButton *_photoShareButton;
    NSInteger _section;
    UISwitch *_shareSwitch;
    UILabel *_shareSwitchLabel;
    UIAlertView *_deleteAlert;
}

- (instancetype)initWithTableView:(UITableView *)tableView
                          section:(NSInteger)section
                            share:(BOOL)share
{
    self = [super init];
    
    if (self)
    {
        _tableView = tableView;
        _section = section;
        
        [self setFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 36.0f)];
        
        _photoDeleteButton = [[UIButton alloc] initWithFrame:CGRectMake(_tableView.bounds.size.width - 36.0f , 2.0f, 32.0f, 32.0f)];
        [_photoDeleteButton addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [_photoDeleteButton setBackgroundImage:[UIImage imageNamed:@"PhotoDelete"] forState:UIControlStateNormal];
        
        _shareSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 150.0f, 30.0f)];
        _shareSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(_tableView.bounds.size.width - 100.0f , 3.0f, 60.0f, 28.0f)];
        _shareSwitchLabel.text = @"Sharing";
        [_shareSwitch addTarget:self action:@selector(changeSwitchAction:) forControlEvents:UIControlEventValueChanged];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 36.0f)];
        background.alpha = 0.6f;
        background.backgroundColor = [UIColor whiteColor];
        
        _deleteAlert = [[UIAlertView alloc] initWithTitle:@"Bitcasa"
                                                  message:@"Do you want to delete this post ?"
                                                 delegate:self
                                        cancelButtonTitle:@"NO"
                                        otherButtonTitles:@"YES", nil];
        
        [self setShare:share];
        
        [self addSubview:background];
        [self addSubview:_photoDeleteButton];
        [self addSubview:_photoShareButton];
        [self addSubview:_shareSwitchLabel];
        [self addSubview:_shareSwitch];
    }
    
    return self;
}

#pragma mark - Private Methods.

- (void)deletePhoto:(UIButton*)sender
{
    [_deleteAlert show];
}

- (void)changeSwitchAction:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectMyPhotoShareButton:withSection:)])
    {
        [self.delegate didSelectMyPhotoShareButton:(sender.on) withSection:_section];
    }
}

- (void)setShare:(BOOL)status
{
    [_shareSwitch setOn:status animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == BUTTON_DELETE_YES_INDEX)
    {
        if ([self.delegate respondsToSelector:@selector(didSelectTimeLineDeleteButtonWithSection:)])
        {
            [self.delegate didSelectTimeLineDeleteButtonWithSection:_section];
        }
    }
}

@end
