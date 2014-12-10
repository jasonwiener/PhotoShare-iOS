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
    
    NSMutableURLRequest *_userAuthRequest;
    NSMutableDictionary *_userAuthHttpBody;
    
    NSString *_appAccountUsername;
    NSString *_appAccountPassword;
}

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
        NSString *userRegistrationUrl = [plistReader appConfigValueForKey:@"BC_USER_REGISTRATION_URL"];
        _appAccountUsername = [plistReader appConfigValueForKey:@"BC_APP_ACCOUNT_USER"];
        _appAccountPassword = [plistReader appConfigValueForKey:@"BC_APP_ACCOUNT_PASSWORD"];
        NSString *userAuthUrl = [plistReader appConfigValueForKey:@"BC_USER_AUTH_URL"];
        
        _session =  [[Session alloc] initWithServerURL:apiServerUrl clientId:clientId clientSecret:secret];
        
        // User Creation HTTP Request & HTTP Body
        _userCreationRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userRegistrationUrl]];
        _userCreationRequest.HTTPMethod = @"POST";
        [_userCreationRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_userCreationRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        _userCreationHttpBody = [NSMutableDictionary dictionary];
        
        // User Auth HTTP Request & HTTP Body
        _userAuthRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userAuthUrl]];
        _userAuthRequest.HTTPMethod = @"POST";
        [_userAuthRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_userAuthRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        _userAuthHttpBody = [NSMutableDictionary dictionary];
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
    [self authenticateWithUsername:username
                           andPassword:password
                            completion:^(BOOL success, NSString *userToken) {
                                
                                if (success) {
                                    self.username = username;
                                    self.userAccessToken = userToken;
                                    
                                    [self authenticateWithUsername:_appAccountUsername
                                                            andPassword:_appAccountPassword
                                                            completion:^(BOOL success, NSString *appToken) {
                                                                if (success) {
                                                                    self.appAccessToken = appToken;
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

#pragma mark - Private Methods
- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                      completion:(void (^)(BOOL status, NSString *token))completion
{
    _userAuthHttpBody[@"username"] = username;
    _userAuthHttpBody[@"password"] = password;
    
    NSError *jsonError = nil;
    _userAuthRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:_userAuthHttpBody options:kNilOptions error:&jsonError];
    
    [NSURLConnection sendAsynchronousRequest:_userAuthRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if ([response respondsToSelector:@selector(statusCode)]) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
                                       NSError *jsonError = nil;
                                       NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                      options:kNilOptions
                                                                                                        error:&jsonError];
                                       if (!jsonError) {
                                           NSString *authToken = dataDictionary[@"auth_token"];
                                           completion(YES, authToken);
                                       }
                                       else {
                                           completion(NO, nil);
                                       }
                                       
                                   }
                                   else {
                                       completion(NO, nil);
                                   }
                               }
                               else {
                                   completion(NO, nil);
                               }
                           }];

}

@end
