//
//  BCFolderService.m
//  PhotoShare
//
//  Created by Nalinda Somasundara on 11/2/14.
//
//

#import <BitcasaSDK/Folder.h>
#import <BitcasaSDK/File.h>
#import <BitcasaSDK/BitcasaAPI.h>
#import <BitcasaSDK/Share.h>
#import "BCFolderService.h"
#import "BCPSFolder.h"

@implementation BCFolderService
{
    BCCredentialsService *_credentialsService;
    NSMutableDictionary *_appFolders;
    NSMutableDictionary *_userPrivateFolders;
    NSMutableDictionary *_userPublicFolders;
    NSMutableDictionary *_sharedFolders;
    NSMutableDictionary *_sharedFolderCache;
}

// Key used to store share link
static NSString *const shareKeyField = @"Share Key";

// PhotoShare users folder name
static NSString *const rootFolderName = @"root";
static NSString *const photoShareFolderName = @"photoshare";
static NSString *const appFolderName = @"app";
static NSString *const usersFolderName = @"users";
static NSString *const privateFolderName = @"private";
static NSString *const publicFolderName = @"public";
static NSString *const metaFileName = @"meta";
static NSString *const sharedFolderName = @"shared";

static NSString *const appUsersLocalFolderName = @"photoshare/app/users";
static NSString *const appMetaLocalFileName = @"photoshare/app/meta";
static NSString *const privateLocalFolderName = @"photoshare/private";
static NSString *const publicLocalFolderName = @"photoshare/public";
static NSString *const appLocalFolderName = @"photoshare/app";
static NSString *const sharedLocalFolderName = @"photoshare/shared";

- (instancetype)initWithCredentialsService:(BCCredentialsService *)credentialsService
{
    self = [super init];
    if (self) {
        _credentialsService = credentialsService;
        
        _appFolders = [NSMutableDictionary dictionary];
        _appFolders[usersFolderName] = [[BCPSFolder alloc] initWithName:usersFolderName parentFolderName:appFolderName isLeaf:YES];
        _appFolders[appFolderName] = [[BCPSFolder alloc] initWithName:appFolderName parentFolderName:photoShareFolderName];
        _appFolders[photoShareFolderName] = [[BCPSFolder alloc] initWithName:photoShareFolderName parentFolderName:rootFolderName];
        
        BCPSFolder *rootFolder = [[BCPSFolder alloc] initWithName:rootFolderName parentFolderName:nil];
        rootFolder.folder = (Folder *)[[Container alloc] initRootContainer];
        _appFolders[rootFolderName] = rootFolder;
        
        BCPSFolder *photoShareFolder = [[BCPSFolder alloc] initWithName:photoShareFolderName parentFolderName:rootFolderName];
        
        _userPrivateFolders = [NSMutableDictionary dictionary];
        _userPrivateFolders[privateFolderName] = [[BCPSFolder alloc] initWithName:privateFolderName parentFolderName:photoShareFolderName isLeaf:YES];
        _userPrivateFolders[photoShareFolderName] = photoShareFolder;
        _userPrivateFolders[rootFolderName] = rootFolder;
        
        _userPublicFolders = [NSMutableDictionary dictionary];
        _userPublicFolders[publicFolderName] = [[BCPSFolder alloc] initWithName:publicFolderName parentFolderName:photoShareFolderName isLeaf:YES];
        _userPublicFolders[photoShareFolderName] = photoShareFolder;
        _userPublicFolders[rootFolderName] = rootFolder;
        
        _sharedFolders = [NSMutableDictionary dictionary];
        _sharedFolders[sharedFolderName] = [[BCPSFolder alloc] initWithName:sharedFolderName parentFolderName:photoShareFolderName isLeaf:YES];
        _sharedFolders[photoShareFolderName] = photoShareFolder;
        _sharedFolders[rootFolderName] = rootFolder;
        
        _sharedFolderCache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)initializeAppFolderStructureWithCompletion:(void (^)(BOOL))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] lastObject];
    
    // Create PhotoShare local folder in documents dir
    _appUsersLocalFolder = [documentsURL URLByAppendingPathComponent:appUsersLocalFolderName
                                                            isDirectory:YES];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:_appUsersLocalFolder
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    
    _appMetaLocalFile = [documentsURL URLByAppendingPathComponent:appMetaLocalFileName isDirectory:NO];
    _appLocalFolder = [documentsURL URLByAppendingPathComponent:appLocalFolderName isDirectory:YES];
    
    [_credentialsService switchAccountContextToType:BCPSAccountTypeApp];
    [self initializeFoldersInStructure:_appFolders withCompletion:^(BOOL status) {
        if (status) {
            [self initializeMetaFileWithCompletion:^(BOOL success) {
                 completion(status);
            }];
        }
    }];
}

- (void)initializePrivateFolderStructureWithCompletion:(void (^)(BOOL))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] lastObject];
    
    // Create PhotoShare local folder in documents dir
    _privateLocalFolder = [documentsURL URLByAppendingPathComponent:privateLocalFolderName
                                                            isDirectory:YES];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:_privateLocalFolder
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    

    [self initializeFoldersInStructure:_userPrivateFolders withCompletion:^(BOOL status) {
        completion(status);
    }];
}

- (void)initializePublicFolderStructureWithCompletion:(void (^)(BOOL, NSString *, NSString *))completion
{
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] lastObject];
    
    // Create PhotoShare local folder in documents dir
    _publicLocalFolder = [documentsURL URLByAppendingPathComponent:publicLocalFolderName
                                                            isDirectory:YES];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:_publicLocalFolder
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    
    [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
    [self initializeFoldersInStructure:_userPublicFolders withCompletion:^(BOOL success) {
        if (success) {
            BCPSFolder *publicFolder = _userPublicFolders[publicFolderName];
            if (!self.shareKey.length) {
                [BitcasaAPI shareItems:@[publicFolder.folder] completion:^(Share *share) {
                    self.shareKey = share.shareKey;
                    completion(success, share.shareKey, publicFolder.folder.url);
                }];
            }
            else {
                completion(success, self.shareKey, publicFolder.folder.url);
            }
        }
        else {
            completion(success, nil, nil);
        }
    }];
}

- (void)initializeSharedFolderStructureWithCompletion:(void (^)(BOOL))completion
{
    [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] lastObject];
    
    // Create Shared local folder in documents dir
    _sharedLocalFolder = [documentsURL URLByAppendingPathComponent:sharedLocalFolderName
                                                       isDirectory:YES];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:_sharedLocalFolder
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    
    
    [self initializeFoldersInStructure:_sharedFolders withCompletion:^(BOOL status) {
        completion(status);
    }];
}

- (void)getSharedRemoteFolderOfUsername:(NSString *)username withCompletion:(void (^)(Folder *))completion
{
    Folder *folder = _sharedFolderCache[username];
    
    if (folder) {
        completion(folder);
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
            [self.sharedRemoteFolder listItemsWithCompletion:^(NSArray *items) {
                Folder *userFolder = nil;
                
                for (Folder *sharedUserFolder in items) {
                    _sharedFolderCache[sharedUserFolder.name] = sharedUserFolder;
                }
                
                userFolder = _sharedFolderCache[username];
                
                if (userFolder) {
                    completion(userFolder);
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_credentialsService switchAccountContextToType:BCPSAccountTypeUser];
                        [self.sharedRemoteFolder createFolder:username completion:^(Container *newDir) {
                            if (newDir) {
                                _sharedFolderCache[username] = newDir;
                            }
                            
                            completion (_sharedFolderCache[username]);
                        }];
                    });
                }
            }];
        });
    }
}

#pragma mark - Property getter/setter overrides

- (Folder *)appUsersRemoteFolder
{
    return ((BCPSFolder *)_appFolders[usersFolderName]).folder;
}

- (Folder *)appRemoteFolder
{
    return ((BCPSFolder *)_appFolders[appFolderName]).folder;
}

- (Folder *)privateRemoteFolder
{
    return ((BCPSFolder *)(_userPrivateFolders[privateFolderName])).folder;
}

- (Folder *)publicRemoteFolder
{
    return ((BCPSFolder *)(_userPublicFolders[publicFolderName])).folder;
}

- (Folder *)photoShareRemoteFolder
{
    return ((BCPSFolder *)_userPublicFolders[photoShareFolderName]).folder;
}

- (Folder *)sharedRemoteFolder
{
    return  ((BCPSFolder *)_sharedFolders[sharedFolderName]).folder;
}

- (NSURL *)photoShareLocalFolder
{
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] lastObject];
    
    return [documentsURL URLByAppendingPathComponent:photoShareFolderName isDirectory:YES];
}

- (NSString *)shareKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:shareKeyField];
}

- (void)setShareKey:(NSString *)shareKey
{
    [[NSUserDefaults standardUserDefaults] setObject:shareKey forKey:shareKeyField];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private Methods
- (void)initializeFoldersInStructure:(NSDictionary *)structure
                      withCompletion:(void (^)(BOOL))completion
{
    NSMutableArray *folders = [NSMutableArray array];
    [structure enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BCPSFolder *psFolder = obj;
        
        if (psFolder.isLeaf) {
            [folders addObject:psFolder];
        }
    }];
    
    if (folders.count) {
        [self initializeFolders:folders
                   currentIndex:0
                    inStructure:structure
                 withCompletion:^(BOOL status) {
                     completion(status);
                 }
        ];
    }
}

- (void)initializeFolders:(NSArray *)folders
             currentIndex:(NSUInteger)index
              inStructure:(NSDictionary *)stucture
           withCompletion:(void (^)(BOOL))completion
{
    if (index >= folders.count) {
        completion(YES);
    }
    else {
        [self initializeFolder:folders[index] inStructure:stucture withCompletion:^(BCPSFolder *psFolder) {
            if (psFolder) {
                [self initializeFolders:folders
                           currentIndex:(index + 1)
                            inStructure:stucture
                         withCompletion:completion];
            }
            else {
                completion(NO);
            }
        }];
    }
}

- (void)initializeFolder:(BCPSFolder *)psFolder
             inStructure:(NSDictionary *)sturcture
          withCompletion:(void (^)(BCPSFolder *psFolder))completion
{
    if (psFolder.folder) {
        completion(psFolder);
    }
    else {
        BCPSFolder *psParentFolder = sturcture[psFolder.parentFolderName];
        if (psParentFolder.folder) {
            [self retrieveFolderName:psFolder.name
                          fromParent:psParentFolder.folder
                      withCompletion:^(Folder *folder) {
                          psFolder.folder = folder;
                          completion(psFolder);
                      }
            ];
        }
        else {
            [self initializeFolder:psParentFolder
                       inStructure:sturcture
                    withCompletion:^(BCPSFolder *returnedPSParentFolder) {
                        if (returnedPSParentFolder && returnedPSParentFolder.folder) {
                            [self retrieveFolderName:psFolder.name
                                          fromParent:returnedPSParentFolder.folder
                                      withCompletion:^(Folder *folder) {
                                          psFolder.folder = folder;
                                          completion(psFolder);
                                      }
                             ];
                        }
                        else {
                            completion(nil);
                        }
                    }
            ];
        }
    }
}

- (void)retrieveFolderName:(NSString *)folderName
                fromParent:(Folder *)parentFolder
            withCompletion:(void (^)(Folder *folder))completion
{
    [parentFolder listItemsWithCompletion:^(NSArray *items) {
        if (items) {
            Folder *folder = nil;
            for (Folder *childFolder in items) {
                if ([childFolder.name isEqualToString:folderName]) {
                    folder = childFolder;
                    completion(folder);
                    break;
                }
            }
            
            if (folder == nil) {
                [self createFolderName:folderName
                        inParentFolder:parentFolder
                        withCompletion:^(Folder *folder) {
                            completion(folder);
                        }
                 ];
            }
        }
        else {
            completion(nil);
        }
    }];
}

- (void)createFolderName:(NSString *)folderName
          inParentFolder:(Folder *)parentFolder
          withCompletion:(void (^)(Folder *folder))completion
{
    [parentFolder createFolder:folderName
                    completion:^(Container *newDir) {
                        completion((Folder *)newDir);
                    }
     ];
}

- (void)initializeMetaFileWithCompletion:(void(^)(BOOL success))completion
{
    [((BCPSFolder *)_appFolders[appFolderName]).folder listItemsWithCompletion:^(NSArray *items) {
        
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
            if ([obj isMemberOfClass:[File class]])
            {
                File *file = (File *)obj;
                
                if ([file.name isEqualToString:metaFileName])
                {
                   _appMetaRemoteFile = file;
                    *stop = YES;
                    completion(YES);
                }
            }
        }];
        
        if (items == nil || _appMetaRemoteFile == nil)
        {
            completion(NO);
        }
    }];
}

@end
