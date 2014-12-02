//
//  BCHistoryViewController.m
//  PhotoShare
//
//  Created by Chathurka on 10/27/14.
//
//

#import "BCHistoryViewController.h"
#import "BCTimeLineCustomCell.h"
#import "BCMyPhotoCustomHeaderView.h"
#import "BCMyPhotoCustomFooterView.h"
#import "BCPhotoShareService.h"
#import "BCUserService.h"
#import "BCPSPhoto.h"
#import "BCPSUser.h"

@implementation BCHistoryViewController
{
    BCPhotoShareService *_photoShareService;
    BCUserService *_userService;
    
    NSMutableArray *_posts;
    NSMutableDictionary *_myPhotoFooterViews;
    
    UIActivityIndicatorView *_activityIndicator;
    
    BOOL _itemRetrieving;
    UIRefreshControl *_refreshControl;
}

-(instancetype)initWithNibName:(NSString *)nibName
                        bundle:(NSBundle *)nibBundle
             photoShareService:(BCPhotoShareService *)photoShareService
                   userService:(BCUserService *)userService
{
    self = [self initWithNibName:nibName bundle:nil];
    
    if (self)
    {
        _photoShareService = photoShareService;
        _userService = userService;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _myPhotoFooterViews = [NSMutableDictionary dictionary];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.center = self.view.center;
    _activityIndicator.hidesWhenStopped = YES;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [self reloadMyphotosWithCompletion:^(BOOL success) {
        
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"My Photos";
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView.superview addSubview:_activityIndicator];
    [self.tableView.superview bringSubviewToFront:_activityIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Mothods

- (void)handleRefresh:(id)sender
{
    [_refreshControl beginRefreshing];
    [self reloadMyphotosWithCompletion:^(BOOL success) {
        [_refreshControl endRefreshing];
    }];
}

- (void)reloadMyphotosWithCompletion:(void(^)(BOOL success))completion
{
    if (_itemRetrieving == NO)
    {
        _itemRetrieving = YES;
        [_photoShareService retrievePhotoDetailsOfCurrentUserWithCompletion:^(NSMutableArray *bcpsPhotos) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _posts = bcpsPhotos ;
                _itemRetrieving = NO;
                _posts = [[_posts sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
                
                [self.tableView reloadData];
                completion(YES);
            });
        }];
    }
    else
    {
        completion(YES);
    }
}

- (BCPSPhoto *)photoforSection:(NSInteger)section
{
    NSInteger postIndex = (_posts.count - 1) - section;
    return (BCPSPhoto*)_posts[postIndex];
}

- (BCMyPhotoCustomFooterView *)footerView:(NSInteger)section
{
    return (BCMyPhotoCustomFooterView *)[_myPhotoFooterViews objectForKey:[NSString stringWithFormat:@"%li",(long)section]];
}

- (void)setFooter:(BCMyPhotoCustomFooterView *)myPhotoFooterView section:(NSInteger)section
{
    [_myPhotoFooterViews setObject:myPhotoFooterView forKey:[NSString stringWithFormat:@"%li",(long)section]];
}

- (void)enableObjects
{
    self.tableView.userInteractionEnabled = YES;
    [_activityIndicator stopAnimating];
}

- (void)disableObjects
{
    self.tableView.userInteractionEnabled = NO;
    [_activityIndicator startAnimating];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_posts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BCPSPhoto *photoCell = [self photoforSection:indexPath.section];
    
    static NSString *cellIdentifier = @"BCTimeLineCellIdentifier";
    BCTimeLineCustomCell *cell = (BCTimeLineCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[BCTimeLineCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTableView:tableView];
    }
    
    cell.photoService = _photoShareService;
    cell.photo = photoCell;
    [cell setSection:indexPath.section];
    [cell startPhotoDownloading];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BCPSPhoto *photo = [self photoforSection:section];
    
    BCMyPhotoCustomHeaderView *timeLineheaderView = [[BCMyPhotoCustomHeaderView alloc] initWithTaleView:self.tableView
                                                                                                caption:photo.caption
                                                                                             sharedTime:photo.sharedTime];
    
    return timeLineheaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 330.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    BCPSPhoto *photo = [self photoforSection:section];
    
    BCMyPhotoCustomFooterView *myPhotoFooterView = [[BCMyPhotoCustomFooterView alloc] initWithTableView:self.tableView
                                                                                                section:section
                                                                                                  share:photo.isShared];
    myPhotoFooterView.delegate = self;
    
    [self setFooter:myPhotoFooterView section:section];
    
    return myPhotoFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 36.0f;
}

#pragma mark - BCUIButtonEventTracking

- (void)didSelectMyPhotoShareButton:(BOOL)state withSection:(NSInteger)section
{
    BCPSPhoto *photo = [self photoforSection:section];
    
    [self disableObjects];
    [_photoShareService uploadPhotoDetails:photo andSharedState:state completion:^(BOOL success) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                BCMyPhotoCustomFooterView *myPhotoFooterView = [self footerView:section];
                [myPhotoFooterView setShare:state];
            });
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTimeLine" object:nil];
        [self enableObjects];
    }];
}

- (void)didSelectTimeLineDeleteButtonWithSection:(NSInteger)section
{
    BCPSPhoto *photo = [self photoforSection:section];
    
    [_photoShareService deletePhoto:photo withCompletion:^(BCPSPhoto *item, BOOL success) {
        //if (success) ios SDK api function is not working correctly.It returns NO if it's deleted also.
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_myPhotoFooterViews removeObjectForKey:[NSString stringWithFormat:@"%li",(long)section]];
                [_posts removeObject:photo];
                
                [self.tableView reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTimeLine" object:nil];
            });
        }
    }];
}

@end
