//
//  BCFriendsViewController.m
//  PhotoShare
//
//  Created by Chathurka on 10/24/14.
//
//

#import "BCFriendsViewController.h"
#import "BCFriendCustomCell.h"
#import "BCUserService.h"
#import "BCCredentialsService.h"
#import "BCFolderService.h"
#import "BCPSUser.h"

@interface BCFriendsViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *searchFriends;

@end

@implementation BCFriendsViewController
{
    UIActivityIndicatorView *_activityIndicator;
    BCUserService *_userService;
    BOOL _itemRetrieving;
    UIRefreshControl *_refreshControl;
}

- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(NSBundle *)nibBundle
                    userService:(BCUserService *)userService
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    
    if (self)
    {
        _userService = userService;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.center = self.view.center;
    _activityIndicator.hidesWhenStopped = YES;
    
    _searchBar.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapAction:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.tableView addGestureRecognizer:tapGesture];
    self.tableView.allowsSelection = NO;
    
    [self reloadFriendListCompletion:^(BOOL success) {
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"Friends";
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

#pragma mark - privete methods

- (void)handleRefresh:(id)sender
{
    [_refreshControl beginRefreshing];
    [self reloadFriendListCompletion:^(BOOL success) {
        [_refreshControl endRefreshing];
    }];
}

- (void)reloadFriendListCompletion:(void(^)(BOOL success))completion
{
    if (_itemRetrieving == NO)
    {
        _itemRetrieving = YES;
        
        [_userService retrieveUserList:^(NSArray *userlist) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (userlist.count)
                {
                    self.friends = [userlist mutableCopy];
                    self.searchFriends = [NSMutableArray arrayWithArray:self.friends];
                    [self.tableView reloadData];
                }
                
                _itemRetrieving = NO;
                completion(YES);
            });
        }];
    }
    else
    {
        completion(YES);
    }
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

- (void)tableViewTapAction:(UIGestureRecognizer *)sender
{
    [_searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BCFriendCellIdentifirer";
    BCFriendCustomCell *cell = (BCFriendCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[BCFriendCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withTableView:tableView];
    }
    
    BOOL followedUser = [_userService.currentUser.friends containsObject:[(_searchFriends[indexPath.row]) lowercaseString]];
    
    cell.row = indexPath.row;
    [cell setFollow:followedUser];
    cell.textLabel.text = self.friends[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchFriends removeAllObjects];
    
    if((searchText.length > 0))
    {
        [_friends enumerateObjectsUsingBlock:^(NSString *friendName, NSUInteger index, BOOL *stop) {
            NSRange range = [[friendName lowercaseString] rangeOfString:[searchText lowercaseString]];
            
            if(range.location != NSNotFound)
            {
                if(range.location == 0)
                {
                    [_searchFriends addObject:friendName];
                }
            }
        }];
    }
    else
    {
        [_searchFriends addObjectsFromArray:_friends];
    }
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchBar:searchBar textDidChange:@""];
    searchBar.text = @"";
    
    [searchBar resignFirstResponder];
}

#pragma mark - BCUIButtonEventTracking

- (void)didSelectFriendFollowButton:(BOOL)state withRow:(NSInteger)row;
{
    [self disableObjects];
    
    NSMutableArray *friends = _userService.currentUser.friends.count > 0 ? _userService.currentUser.friends : [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    BCFriendCustomCell *selectedCell = (BCFriendCustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *friendName = self.friends[row];
    if (state)
    {
        [friends addObject:friendName];
    }
    else
    {
        [friends removeObject:friendName];
    }
    
    _userService.currentUser.friends = friends;
    
    [_userService saveCurrentUserWithCompletion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [selectedCell setFollow:state];
            [self enableObjects];
            
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UITableViewCell class]])
    {
        return NO;
    }
    
    if ([touch.view.superview isKindOfClass:[UITableViewCell class]])
    {
        return NO;
    }
    
    if ([touch.view.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        return NO;
    }
    
    return YES;
}

@end
