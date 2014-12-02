//
//  BCPhotoShareService.m
//  PhotoShare
//
//  Created by Nalinda Somasundara on 10/17/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <objc/runtime.h>
#import <BitcasaSDK/BitcasaAPI.h>
#import <BitcasaSDK/Container.h>
#import <BitcasaSDK/Folder.h>
#import <BitcasaSDK/File.h>
#import <BitcasasDK/Share.h>
#import "BCPhotoShareService.h"
#import "BCPSPhoto.h"
#import "BCFileTransfer.h"
#import "BCCredentialsService.h"
#import "BCFolderService.h"
#import "BCFileTransferService.h"
#import "BCUserService.h"
#import "BCPSUser.h"

@implementation BCPhotoShareService
{
    // The credentials service instance.
    BCCredentialsService *_credentialsService;
    
    // The folder service instance.
    BCFolderService *_folderService;
    
    // The file tranfeer service instance.
    BCFileTransferService *_fileTransferService;
    
    // The user service instance.
    BCUserService *_userService;
    
    // Array containing BCPSPhoto objects after deserializing meta file.
    NSMutableArray *_photoDetails;
    
    // Dictionary containing BCPSPhoto objects used to set and get File objects.
    NSMutableDictionary *_photoDetailsCache;
}

static NSString *const publicFolderName = @"public";

- (instancetype)initWithCredentialsService:(BCCredentialsService *)credentialsService
                          andFolderService:(BCFolderService *)folderService
                    andFileTransferService:(BCFileTransferService *)fileTransferService
                            andUserService:(BCUserService *)userService
{
    if (self = [super init]) {
        _credentialsService = credentialsService;
        _folderService = folderService;
        _fileTransferService = fileTransferService;
        _userService = userService;
        _photoDetails = [NSMutableArray array];
        _photoDetailsCache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)retrievePhotoDetailsWithCompletion:(void (^)(BOOL success, NSArray *photoDetails))handler
{
    NSMutableArray *photoDetails = [NSMutableArray array];
    
    [self retrieveAllPhotoDetailsWithCompletion:^(NSArray *allPhotoDetails) {
        for (BCPSPhoto *photo in allPhotoDetails) {
            
            if ([photo.username isEqualToString:_userService.currentUser.username] || [self isFriendsSharedPhoto:photo]) {
                [photoDetails addObject:photo];
            }
        }
        
        [self receiveSharesOfUsers:_userService.currentUser.friends withCompletion:^(BOOL success) {
            handler(success, photoDetails);
        }];
    }];
}

- (void)retrievePhotoDetailsOfCurrentUserWithCompletion:(void (^)(NSMutableArray *bcpsPhotos))handler
{
    NSMutableArray *photoDetails = [NSMutableArray array];
    
    [self retrieveAllPhotoDetailsWithCompletion:^(NSArray *allPhotoDetails) {
        for (BCPSPhoto *photo in allPhotoDetails) {
            if ([photo.username isEqualToString:_userService.currentUser.username]) {
                [photoDetails addObject:photo];
            }
        }
        handler(photoDetails);
    }];
}

- (void)uploadPhotoDetails:(BCPSPhoto *)photo completion:(void (^)(BOOL))handler
{
    [_photoDetails addObject:photo];
    [self saveAllPhotoDetailsWithCompletion:^(BOOL success) {
        handler(success);
    }];
}

- (void)uploadPhotoDetails:(BCPSPhoto *)photo andFile:(NSURL *)fileURL withCompletion:(void (^)(BOOL))handler
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    BCFileTransfer *fileTransfer = [[BCFileTransfer alloc] init];
    fileTransfer.referenceObject = photo;
    __weak BCFileTransfer *weakFT = fileTransfer;
    
    weakFT.uploadCompletion = ^(File *file, NSString *filename, NSObject *refObject, NSError *error) {
        BCPSPhoto *photo = (BCPSPhoto *)refObject;
        if (error == nil) {
            photo.uuid = uuid;
            
            [self uploadPhotoDetails:photo completion:^(BOOL success) {
                handler(success);
            }];
        }
        else
        {
            handler(NO);
        }
    };
    [_fileTransferService addFileTransferReference:fileTransfer forFilename:uuid];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (photo.isShared)
    {
        NSURL *destURL = [_folderService.publicLocalFolder URLByAppendingPathComponent:uuid];
        
        [fileManager removeItemAtURL:destURL error:&error];
        [fileManager moveItemAtURL:fileURL toURL:destURL error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
            [_folderService.publicRemoteFolder uploadContentsOfFile:destURL delegate:_fileTransferService];
        });
    }
    else
    {
        NSURL *destURL = [_folderService.privateLocalFolder URLByAppendingPathComponent:uuid];
        
        [fileManager removeItemAtURL:destURL error:&error];
        [fileManager moveItemAtPath:fileURL.path toPath:destURL.path error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
            [_folderService.privateRemoteFolder uploadContentsOfFile:destURL delegate:_fileTransferService];
        });
    }
}

- (void)retrievePhotoFileFromPhotoDetails:(BCPSPhoto *)photoDetails withCompletion:(void (^)(BCPSPhoto *, NSURL *))handler
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *destURL = nil;
    
    if ([photoDetails.username isEqualToString:_userService.currentUser.username] && !(photoDetails.isShared))
    {
        destURL = [_folderService.privateLocalFolder URLByAppendingPathComponent:photoDetails.uuid];
    }
    else
    {
        destURL = [_folderService.publicLocalFolder URLByAppendingPathComponent:photoDetails.uuid];
    }
    
    photoDetails.fileURL = destURL;
    
    BCFileTransfer *fileTransfer = [[BCFileTransfer alloc] init];
    fileTransfer.referenceObject = photoDetails;
    __weak BCFileTransfer *weakFT = fileTransfer;
    
    weakFT.downloadCompletion = ^(NSString *filename, NSObject *refObject, NSURL *locationURL, NSError *error) {
        BCPSPhoto *photo = (BCPSPhoto *)refObject;
        if (error == nil) {
            
            [fileManager removeItemAtURL:destURL error:nil];
            [fileManager moveItemAtURL:locationURL toURL:destURL error:nil];
            
            handler(photo, destURL);
        }
    };
    
    if ([fileManager fileExistsAtPath:[photoDetails.fileURL path]]) {
        if (photoDetails.photoFile) {
            handler(photoDetails, photoDetails.fileURL);
        }
        else {
            [self retrieveFileFromPhotoDetails:photoDetails withCompletion:^(File *file) {
                photoDetails.photoFile = file;
                handler(photoDetails, photoDetails.fileURL);
            }];
        }
    }
    else
    {
        [self retrieveFileFromPhotoDetails:photoDetails withCompletion:^(File *file) {
            if (file)
            {
                photoDetails.photoFile = file;
                [_fileTransferService addFileTransferReference:fileTransfer forFilename:[[file url] lastPathComponent]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
                    [photoDetails.photoFile downloadWithDelegate:_fileTransferService];
                });
            }
            else
            {
                handler(photoDetails, nil);
            }
        }];
    }
}

- (void)deletePhoto:(BCPSPhoto *)photo withCompletion:(void (^)(BCPSPhoto *, BOOL))handler
{
    if (_folderService.appMetaRemoteFile) {
        [_photoDetails removeObject:photo];
        [_photoDetailsCache removeObjectForKey:photo.uuid];
        
        [self saveAllPhotoDetailsWithCompletion:^(BOOL success) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [photo.photoFile deleteWithCompletion:^(BOOL success) {
                        handler(photo, success);
                    }];
                });
            }
            else {
                [_photoDetails addObject:photo];
                _photoDetailsCache[photo.uuid] = photo;
            }
        }];
    }
    else
    {
        handler(photo, NO);
    }
}

- (void)uploadPhotoDetails:(BCPSPhoto *)photo andSharedState:(BOOL)sharedState completion:(void (^)(BOOL))handler
{
    Folder *destRemoteFolder = sharedState ? _folderService.publicRemoteFolder: _folderService.privateRemoteFolder;
    NSURL *destURL = [(sharedState ? _folderService.publicLocalFolder:_folderService.privateLocalFolder) URLByAppendingPathComponent:photo.uuid isDirectory:NO];
    NSURL *localFileURL = photo.fileURL;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [photo.photoFile moveToDestinationContainer:destRemoteFolder completion:^(Item *movedItem) {
            if (movedItem)
            {
                BCPSPhoto *cachedPhoto = _photoDetailsCache[movedItem.name];
                cachedPhoto.photoFile = (File *)movedItem;
                cachedPhoto.isShared = sharedState;
                cachedPhoto.fileURL = destURL;
                
                [self uploadPhotoDetails:cachedPhoto completion:^(BOOL success) {
                    if (success)
                    {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtURL:destURL error:nil];
                        [fileManager moveItemAtURL:localFileURL toURL:destURL error:nil];
                    }
                    
                    handler(success);
                }];
            }
            else
            {
                handler(NO);
            }
        }];
    });
}

- (void)deletePhotosOfUser:(NSString *)username withCompletion:(void (^)(BOOL))handler
{
    [self retrieveAllPhotoDetailsWithCompletion:^(NSArray *photos) {
        for (BCPSPhoto *photo in photos) {
            if ([photo.username isEqualToString:username]) {
                [_photoDetails removeObject:photo];
                [_photoDetailsCache removeObjectForKey:photo.uuid];
            }
        }
        
        [self saveAllPhotoDetailsWithCompletion:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
                [_folderService.photoShareRemoteFolder deleteWithCompletion:^(BOOL success) {
                    if (success) {
                        [[NSFileManager defaultManager] removeItemAtURL:_folderService.photoShareLocalFolder error:nil];
                        _folderService.shareKey = @"";
                    }
                    
                    handler(success);
                }];
            });
        }];
    }];
}

#pragma mark - Private Methods
- (void)retrieveFileFromPhotoDetails:(BCPSPhoto *)photo withCompletion:(void (^)(File *))handler
{
    if (photo.photoFile) {
        handler(photo.photoFile);
    }
    else {
        
        if ([photo.username isEqualToString:_userService.currentUser.username]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
                
                Folder *remoteFolder = photo.isShared ? _folderService.publicRemoteFolder : _folderService.privateRemoteFolder;
                [self getPhotoFilesFromFolder:remoteFolder withCompletion:^(BOOL success) {
                    handler(photo.photoFile);
                }];
            });
        }
        else {
            [_folderService getSharedRemoteFolderOfUsername:photo.username withCompletion:^(Folder *sharedFolder) {
                if (sharedFolder) {
                    [self getPhotoFilesFromPublicFolder:sharedFolder withCompletion:^(BOOL success) {
                        if (success && photo.photoFile) {
                            handler(photo.photoFile);
                        }
                        else {
                            handler(nil);
                        }
                    }];
                }
                else {
                    handler(nil);
                }
            }];
        }
    }
}

- (void)retrieveAllPhotoDetailsWithCompletion:(void (^)(NSArray *))handler
{
    BCFileTransfer *fileTransfer = [[BCFileTransfer alloc] init];
    __weak BCFileTransfer *weakFT = fileTransfer;
    weakFT.downloadCompletion = ^(NSString *filename, NSObject *referenceObject, NSURL *locationURL, NSError *error) {
        if (error == nil) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:_folderService.appMetaLocalFile error:nil];
            [fileManager moveItemAtURL:locationURL toURL:_folderService.appMetaLocalFile error:nil];
            
            NSInputStream *inputStream = [NSInputStream inputStreamWithURL:_folderService.appMetaLocalFile];
            [inputStream open];
            NSArray *array = [NSJSONSerialization JSONObjectWithStream:inputStream options:kNilOptions error:nil];
            [inputStream close];
            
            if ([array isKindOfClass:[NSDictionary class]])
            {
                [_folderService initializeMetaFileWithCompletion:^(BOOL success) {
                    if (success)
                    {
                        [self retrieveAllPhotoDetailsWithCompletion:^(NSArray *array) {
                            handler(_photoDetails);
                        }];
                    }
                }];
            }
            else
            {
                [array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
                    BCPSPhoto *photo = [[BCPSPhoto alloc] initWithDictionary:dictionary];
                    _photoDetailsCache[photo.uuid] = photo;
                }];
            }
            
            _photoDetails = [NSMutableArray array];
            for (NSString *key in _photoDetailsCache) {
                [_photoDetails addObject:_photoDetailsCache[key]];
            }
            
            handler(_photoDetails);
        }
    };
    
    if (_folderService.appMetaRemoteFile) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
            [_fileTransferService addFileTransferReference:fileTransfer forFilename:[[_folderService.appMetaRemoteFile url] lastPathComponent]];
            [_folderService.appMetaRemoteFile downloadWithDelegate:_fileTransferService];
        });
    }
    else {
        NSMutableArray *bcpsPhotos = [NSMutableArray array];
        _photoDetails = bcpsPhotos;
        handler(_photoDetails);
    }
}

- (void)saveAllPhotoDetailsWithCompletion:(void (^)(BOOL))handler
{
    NSMutableArray *rootArray = [[NSMutableArray alloc] init];
    
    [_photoDetails enumerateObjectsUsingBlock:^(BCPSPhoto *photo, NSUInteger index, BOOL *stop) {
        [rootArray addObject:[photo dictionaryRepresentation]];
    }];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rootArray
                                                       options:0
                                                         error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    if (jsonString) {
        
        [[NSFileManager defaultManager] removeItemAtURL:_folderService.appMetaLocalFile
                                                  error:nil];
        
        [jsonString writeToURL:_folderService.appMetaLocalFile
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
        
        BCFileTransfer *fileTransfer = [[BCFileTransfer alloc] init];
        __weak BCFileTransfer *weakFT = fileTransfer;
        weakFT.uploadCompletion = ^(File *file, NSString *filename, NSObject *referenceObject, NSError *error) {
            _folderService.appMetaRemoteFile = file;
            handler(error == nil);
        };
        
        [_fileTransferService addFileTransferReference:fileTransfer forFilename:[_folderService.appMetaLocalFile lastPathComponent]];
        
        if (_folderService.appMetaRemoteFile) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
                [_folderService.appMetaRemoteFile deleteWithCompletion:^(BOOL success) {
                    if (success) {
                        [_folderService.appRemoteFolder uploadContentsOfFile:_folderService.appMetaLocalFile
                                                                    delegate:_fileTransferService];
                    }
                    else {
                        handler(NO);
                    }
                }];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
                [_folderService.appRemoteFolder uploadContentsOfFile:_folderService.appMetaLocalFile delegate:_fileTransferService];
            });
        }
    }
}

- (BOOL)isFriendsSharedPhoto:(BCPSPhoto *)photo
{
    BOOL isFriendsSharedPhoto = NO;
    
    if (photo.isShared) {
        for (NSString *name in _userService.currentUser.friends) {
            if ([photo.username isEqualToString:name]) {
                isFriendsSharedPhoto = YES;
                break;
            }
        }
    }
    
    return isFriendsSharedPhoto;
}

- (void)getPhotoFilesFromFolder:(Folder *)folder withCompletion:(void (^)(BOOL))handler
{
    if (folder) {
        [folder listItemsWithCompletion:^(NSArray *items) {
            for (File *file in items) {
                BCPSPhoto *photo = _photoDetailsCache[file.name];
                photo.photoFile = file;
            }
            
            handler(YES);
        }];
    }
    else {
        handler(NO);
    }
}

- (void)getPhotoFilesFromPublicFolder:(Folder *)folder withCompletion:(void (^)(BOOL))handler
{
    if (folder) {
        [folder listItemsWithCompletion:^(NSArray *items) {
            for (Folder *folder in items) {
                if ([folder.name isEqualToString:publicFolderName]) {
                    [self getPhotoFilesFromFolder:folder withCompletion:^(BOOL success) {
                        handler(success);
                    }];
                    break;
                }
            }
        }];
    }
    else {
        handler(NO);
    }
}

#pragma mark - Receive Shares
- (void)receiveSharesOfUsers:(NSArray *)userNames withCompletion:(void (^)(BOOL success))handler
{
    [self receiveShareOfUsers:userNames atIndex:0 withCompletion:^(BOOL success) {
        handler(success);
    }];
}

- (void)receiveShareOfUsers:(NSArray *)userNames atIndex:(NSUInteger)index withCompletion:(void (^)(BOOL success))handler
{
    if (index < [userNames count]) {
        NSString *userName = userNames[index];
        __block NSUInteger nextIndex = ++index;
        __block NSArray *bUserNames = userNames;
        [_userService retrieveUserByUsername:userName enableCache:YES completion:^(BCPSUser *user) {
            if (user) {
                [self receiveShareOfUser:user withCompletion:^(Folder *receivedFolder, BOOL success) {
                    if (success) {
                        if (nextIndex < [userNames count]) {
                            [self receiveShareOfUsers:bUserNames atIndex:nextIndex withCompletion:^(BOOL success) {
                                handler(success);
                            }];
                        }
                        else {
                            handler(success);
                        }
                    }
                    else {
                        handler(NO);
                    }
                }];
            }
            else {
                handler(NO);
            }
        }];
    }
    else {
        handler(NO);
    }
}


- (void)receiveShareOfUser:(BCPSUser *)user withCompletion:(void (^)(Folder *receivedFolder, BOOL success))handler
{
    Share *share = [[Share alloc] init];
    share.shareKey = user.publicFolderSharedKey;
    
    if (share.shareKey) {
        [_folderService getSharedRemoteFolderOfUsername:user.username withCompletion:^(Folder *sharedFolder) {
            __weak Folder *wSharedFolder = sharedFolder;
            if (sharedFolder) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
                    [sharedFolder addShare:share whenExists:BCShareExistsOverwrite completion:^(bool success) {
                        handler(wSharedFolder, success);
                    }];
                });
            }
            else {
                handler(nil, NO);
            }
        }];
    }
    else {
        handler(nil, NO);
    }
}


@end
