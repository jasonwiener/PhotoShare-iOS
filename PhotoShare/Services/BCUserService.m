//
//  BCUserService.m
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/28/14.
//
//

#import <BitcasaSDK/Container.h>
#import <BitcasaSDK/Folder.h>
#import <BitcasaSDK/BitcasaAPI.h>
#import <BitcasaSDK/File.h>
#import "BCPlistReader.h"
#import "BCUserService.h"
#import "BCPSUser.h"
#import "BCCredentialsService.h"
#import "BCFolderService.h"
#import "BCFileTransferService.h"
#import "BCFileTransfer.h"


@implementation BCUserService
{
    NSArray *_users;
    File *_userFile;
    BCCredentialsService *_credentialsService;
    BCFolderService *_folderService;
    BCFileTransferService *_fileTransferService;
}

- (instancetype)initWithCredentialsService:(BCCredentialsService *)credentialsService
                          andFolderService:(BCFolderService *)folderService
                    andFileTransferService:(BCFileTransferService *)fileTransferService
{
    self = [super init];
    if (self) {
        _credentialsService = credentialsService;
        _folderService = folderService;
        _fileTransferService = fileTransferService;
    }
    
    return self;
}

- (void)retrieveCurrentUser:(void (^)(BCPSUser *))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
    
    [self retrieveUserByUsername:_credentialsService.username completion:^(BCPSUser *user) {
        self.currentUser = user;
        completion(user);
    }];
}

- (void)saveCurrentUserWithCompletion:(void (^)(BOOL))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
    
    [self saveUser:self.currentUser withCompletion:^(BOOL success) {
        completion(success);
    }];
}

- (void)retrieveUserList:(void (^)(NSArray *userlist))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
    
    __block NSMutableArray *userList = [[NSMutableArray alloc] init];
    
    if (_folderService.appUsersRemoteFolder) {
        
        [_folderService.appUsersRemoteFolder listItemsWithCompletion:^(NSArray *items) {
            
                [items enumerateObjectsUsingBlock:^(File *file, NSUInteger index, BOOL *stop) {
                    
                    if (self.currentUser.username.length > 0 && file.name.length > 0 && ![self.currentUser.username isEqualToString:file.name])
                    {
                        [userList addObject:file.name];
                    }
                }];
            
            completion(userList);
        }];
    }
}

- (void)retrieveUserByUsername:(NSString *)username completion:(void (^)(BCPSUser *user))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
    
    if (_folderService.appUsersRemoteFolder) {
        [_folderService.appUsersRemoteFolder listItemsWithCompletion:^(NSArray *items) {
            
            BCFileTransfer *fileTransfer = [[BCFileTransfer alloc] init];
            fileTransfer.downloadCompletion = ^(NSString *filename, NSObject *refObject, NSURL *locationURL, NSError *error) {
                BCPSUser *user = nil;
                if (error == nil) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSURL *destURL = [_folderService.appUsersLocalFolder URLByAppendingPathComponent:username];
                    
                    if ([fileManager fileExistsAtPath:locationURL.path])
                    {
                        [fileManager removeItemAtURL:destURL error:nil];
                        [fileManager moveItemAtURL:locationURL toURL:destURL error:nil];
                    }
                    
                    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:[destURL path]
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:nil];
                    user = [[BCPSUser alloc] initWithJSON:jsonString];
                    
                    if (![user.username length]) {
                        user.username = username;
                    }
                    
                    completion(user);
                }
            };
            
            File *userFile = nil;
            for (File *file in items) {
                if ([file.name isEqualToString:username]) {
                    if ([_credentialsService.username isEqualToString:file.name]) {
                        _userFile = file;
                    }
                    
                    userFile = file;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
                        [_fileTransferService addFileTransferReference:fileTransfer forFilename:[file.url lastPathComponent]];
                        [file downloadWithDelegate:_fileTransferService];
                    });
                    
                    break;
                }
            }
            
            if (userFile == nil) {
                BCPSUser *user = [[BCPSUser alloc] init];
                user.username = username;
                completion(user);
            }
        }];
    }
    else {
        completion(nil);
    }
}

- (void)retrieveUserByUsername:(NSString *)username enableCache:(BOOL)enableCache completion:(void (^)(BCPSUser *))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
    
    BOOL fileExists = NO;
    if (enableCache) {
        NSURL *cachedFile = [_folderService.appUsersLocalFolder URLByAppendingPathComponent:username];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        fileExists = [fileManager fileExistsAtPath:[cachedFile path]];
        if (fileExists) {
            NSString *jsonString = [[NSString alloc] initWithContentsOfFile:[cachedFile path]
                                                                   encoding:NSUTF8StringEncoding
                                                                      error:nil];
            BCPSUser *user = [[BCPSUser alloc] initWithJSON:jsonString];
            completion(user);
        }
    }
    fileExists = NO;
    if (!fileExists) {
        [self retrieveUserByUsername:username completion:completion];
    }
}

- (void)removeAccountWithCompletion:(void (^)(BOOL))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
    
    if (_userFile) {
        [_userFile deleteWithCompletion:^(BOOL success) {
            completion(success);
        }];
    }
}

#pragma mark - Private Methods
- (void)saveUser:(BCPSUser *)user withCompletion:(void (^)(BOOL success))completion
{
    NSString *jsonString = [user JSONRepresentation];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *destURL = [_folderService.appUsersLocalFolder URLByAppendingPathComponent:_credentialsService.username];
    [fileManager removeItemAtURL:destURL error:nil];
    
    BOOL fileCreated = [jsonString writeToURL:destURL
                                   atomically:NO
                                     encoding:NSUTF8StringEncoding error:nil];
    
    BCFileTransfer *fileTransfer = [[BCFileTransfer alloc] init];
    fileTransfer.uploadCompletion = ^(File *file, NSString *filename, NSObject *referenceObject, NSError *error) {
        _userFile = file;
        completion(error == nil);
    };
    
    if (fileCreated) {
        [_fileTransferService addFileTransferReference:fileTransfer forFilename:[destURL lastPathComponent]];
        if (_userFile) {
            [_userFile deleteWithCompletion:^(BOOL success) {
                if (success) {
                    [_folderService.appUsersRemoteFolder uploadContentsOfFile:destURL delegate:_fileTransferService];
                }
                else {
                    completion(NO);
                }
            }];
        }
        else {
            [_folderService.appUsersRemoteFolder uploadContentsOfFile:destURL delegate:_fileTransferService];
        }
    }
    else {
        completion(NO);
    }
}

@end
