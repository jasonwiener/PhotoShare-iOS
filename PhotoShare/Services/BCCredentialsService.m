//
//  BCCredentialsService.m
//  PhotoShare
//
//  Created by Nalinda Somasundara on 11/1/14.
//
//

#import <BitcasaSDK/Credentials.h>
#import <BitcasaSDK/Session.h>
#import "BCCredentialsService.h"
#import "BCPlistReader.h"

@interface BCCredentialsService ()

// User Access Token
@property (nonatomic, copy) NSString *userAccessToken;

// App Access Token
@property (nonatomic, copy) NSString *appAccessToken;

@end

@implementation BCCredentialsService
{
    Session *_session;
    NSMutableURLRequest *_userCreationRequest;
    NSMutableDictionary *_userCreationHttpBody;
}

// App Account credentials
static NSString *const appAccountUsername = @"nalinda@calcey.com";
static NSString *const appAccountPassword = @"user@123";

// Keys used to store access tokens in User Defaults
static NSString *const userAccessTokenKey = @"User Access Token Key";
static NSString *const appAccessTokenKey = @"App Access Token Key";

// Key used to store username in User Defaults
static NSString *const usernameKey = @"Username Key";

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        BCPlistReader *plistReader = [[BCPlistReader alloc] initWithFileName:@"BitcasaConfig"];
        
        NSString *apiServerUrl = [plistReader appConfigValueForKey:@"BC_API_SERVER_URL"];
        NSString *clientId = [plistReader appConfigValueForKey:@"BC_CLIENT_ID"];
        NSString *secret = [plistReader appConfigValueForKey:@"BC_SECRET"];
        NSString *adminId = [plistReader appConfigValueForKey:@"BC_ADMIN_ID"];
        NSString *adminSecret = [plistReader appConfigValueForKey:@"BC_ADMIN_SECRET"];
        NSString *userRegistrationUrl = [plistReader appConfigValueForKey:@"BC_USER_REGISTRATION_URL"];
        
        _session =  [[Session alloc] initWithServerURL:apiServerUrl clientId:clientId clientSecret:secret];
        _userAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:userAccessTokenKey];
        _appAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:appAccessTokenKey];
        _username = [[NSUserDefaults standardUserDefaults] objectForKey:usernameKey];
        
         _userCreationRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userRegistrationUrl]];
        _userCreationRequest.HTTPMethod = @"POST";
        [_userCreationRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_userCreationRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        _userCreationHttpBody = [[NSMutableDictionary alloc] init];
        [_userCreationHttpBody setValue:apiServerUrl forKey:@"api_server"];
        [_userCreationHttpBody setValue:clientId forKey:@"client_id"];
        [_userCreationHttpBody setValue:secret forKey:@"secret_key"];
        [_userCreationHttpBody setValue:adminId forKey:@"admin_id"];
        [_userCreationHttpBody setValue:adminSecret forKey:@"admin_secret"];
    }
    
    return self;
}

- (void)switchAccountContextToType:(BCPSAccountType)type
{
    Credentials *credentials = [Credentials sharedInstance];
    if (type == BCPSAccountTypeApp) {
        credentials.accessToken = self.appAccessToken;
    }
    else {
        credentials.accessToken = self.userAccessToken;
    }
}

- (void)signInWithUsername:(NSString *)username
               andPassword:(NSString *)password
                completion:(void (^)(BOOL))completion
{
    [_session authenticateWithUsername:username
                           andPassword:password
                            completion:^(BOOL success) {
                                
                                if (success) {
                                    self.username = username;
                                    self.userAccessToken = [NSString stringWithString:[Credentials sharedInstance].accessToken];
                                    
                                    [_session authenticateWithUsername:appAccountUsername
                                                            andPassword:appAccountPassword
                                                            completion:^(BOOL success) {
                                                                if (success) {
                                                                    self.appAccessToken = [NSString stringWithString:[Credentials sharedInstance].accessToken];
                                                                    completion(YES);
                                                                }
                                                                else {
                                                                    completion(NO);
                                                                }
                                                            }
                                     ];
                                }
                                else {
                                    completion(NO);
                                }
                            }
     ];
}

- (void)signUpWithUsername:(NSString *)username
                  password:(NSString *)password
                 firstName:(NSString *)firstName
                  lastName:(NSString *)lastName
                completion:(void (^)(BOOL success))completion
{
    [_userCreationHttpBody setValue:username forKey:@"username"];
    [_userCreationHttpBody setValue:password forKey:@"password"];
    [_userCreationHttpBody setValue:firstName forKey:@"first_name"];
    [_userCreationHttpBody setValue:lastName forKey:@"last_name"];
    
    NSError *jsonError;
    _userCreationRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:_userCreationHttpBody options:kNilOptions error:&jsonError];
    
    NSURLResponse *response;
    NSError *error;
    
    [NSURLConnection sendSynchronousRequest:_userCreationRequest returningResponse:&response error:&error];
    if ([response respondsToSelector:@selector(statusCode)])
    {
       completion([((NSHTTPURLResponse *)response) statusCode] == 201);
    }
    else
    {
        completion(NO);
    }
}


- (BOOL)isAuthenticated
{
    return [_session isLinked];
}

- (void)clearAuthKey
{
    [_session unlink];
}

#pragma mark - Property setters
- (void)setUserAccessToken:(NSString *)userAccessToken
{
    _userAccessToken = [NSString stringWithString:userAccessToken];
    
    [[NSUserDefaults standardUserDefaults] setObject:_userAccessToken forKey:userAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAppAccessToken:(NSString *)appAccessToken
{
    _appAccessToken = [NSString stringWithString:appAccessToken];
    
    [[NSUserDefaults standardUserDefaults] setObject:_appAccessToken forKey:appAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setUsername:(NSString *)username
{
    _username = [NSString stringWithString:username];
    
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:usernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
