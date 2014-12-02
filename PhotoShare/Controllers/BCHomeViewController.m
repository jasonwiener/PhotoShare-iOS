//
//  BCHomeViewController.m
//  PhotoShare
//
//  Created by Chathurka on 10/24/14.
//
//

#import "BCHomeViewController.h"
#import "BCTimeLineCustomCell.h"
#import "BCTimeLineCustomHeaderView.h"
#import "BCTimeLineCustomFooterView.h"
#import "BCPhotoShareService.h"
#import "BCPSPhoto.h"
#import "BCUserService.h"
#import "BCPSUser.h"

@implementation BCHomeViewController
{
    __block NSMutableArray *_posts;
    UIActivityIndicatorView *_activityIndicator;
    NSMutableDictionary *_timeLineFooterViews;

    BCPhotoShareService *_photoShareService;
    BCUserService *_userService;
    
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
    
     _timeLineFooterViews = [NSMutableDictionary dictionary];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.center = self.view.center;
    _activityIndicator.hidesWhenStopped = YES;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];

    [self reloadTimeLineCompletion:^(BOOL success) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefresh:) name:@"reloadTimeLine" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"PhotoShare";
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods.

- (void)handleRefresh:(id)sender
{
    [_refreshControl beginRefreshing];
    [self reloadTimeLineCompletion:^(BOOL success) {
        [_refreshControl endRefreshing];
    }];
}

- (void)reloadTimeLineCompletion:(void(^)(BOOL success))completion
{
    if (_itemRetrieving == NO)
    {
        _itemRetrieving = YES;
        [_photoShareService retrievePhotoDetailsWithCompletion:^(BOOL success, NSArray *bcpsPhotos) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _posts = [bcpsPhotos mutableCopy];
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

- (BCTimeLineCustomFooterView *)footerView:(NSInteger)section
{
    return (BCTimeLineCustomFooterView *)[_timeLineFooterViews objectForKey:[NSString stringWithFormat:@"%li",(long)section]] ;
}

- (void)setFooter:(BCTimeLineCustomFooterView *)timeLineFooterView section:(NSInteger)section
{
    [_timeLineFooterViews setValue:timeLineFooterView forKey:[NSString stringWithFormat:@"%li",(long)section]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 330.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BCPSPhoto *photoCell = [self photoforSection:section];
    
    BCTimeLineCustomHeaderView *timeLineHeaderView = [[BCTimeLineCustomHeaderView alloc] initWithTaleView:self.tableView
                                                                                                 username:photoCell.username
                                                                                                  caption:photoCell.caption
                                                                                               sharedTime:photoCell.sharedTime];
    return timeLineHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 36.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    BCPSPhoto *photoCell = [self photoforSection:section];
    
    BOOL likeState = [photoCell.likedUsers containsObject:_userService.currentUser.username];
    BCTimeLineCustomFooterView *timeLineFooterView = [[BCTimeLineCustomFooterView alloc] initWithTableView:self.tableView
                                                                                                   section:section
                                                                                                 likeCount:(int)photoCell.likedUsers.count
                                                                                                      like:likeState];
    timeLineFooterView.delegate = self;
    [self setFooter:timeLineFooterView section:section];
    
    return timeLineFooterView;
}

#pragma mark - BCUIButtonEventTracking

- (void)didSelectTimeLineLikeButton:(BOOL)state withSection:(NSInteger)section
{
    BCPSPhoto *photo = [self photoforSection:section];
    
    if (state)
    {
        [photo.likedUsers addObject:_userService.currentUser.username];
    }
    else
    {
        [photo.likedUsers removeObject:_userService.currentUser.username];
    }
    
    [self disableObjects];
    
    [_photoShareService uploadPhotoDetails:photo completion:^(BOOL success) {
       dispatch_async(dispatch_get_main_queue(), ^{
        if (success)
        {
            BCTimeLineCustomFooterView *timeLineFooterView = [self footerView:section];
            [timeLineFooterView setLike:state];
        }
        [self enableObjects];
       });
    }];
}

@end
