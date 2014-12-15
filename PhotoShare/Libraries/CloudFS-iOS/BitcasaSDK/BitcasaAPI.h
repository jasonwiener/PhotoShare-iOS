//
//  BitcasaAPI.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;
@class File;
@protocol TransferDelegate <NSObject>
@optional
#pragma mark - download
- (void)itemAtPath:(NSString*)itemPath didCompleteDownloadToURL:(NSURL*)locationURL error:(NSError*)err;
- (void)itemAtPath:(NSString*)itemPath didDownload:(int64_t)totalBytesWritten outOfTotal:(int64_t)totalBytesExpectedToWrite;

#pragma mark - upload
- (void)file:(File*)file didCompleteUploadWithError:(NSError*)err;
- (void)fileAtPath:(NSString*)filePath didUpload:(int64_t)totalBytesUploaded outOfTotal:(int64_t)totalBytesExpectedToWrite;
@end

@class Container;
@class Folder;
@class Share;
@class User;
@class Account;
@interface BitcasaAPI : NSObject

typedef enum {
    BCShareExistsFail,
    BCShareExistsOverwrite,
    BCShareExistsRename
    
} BCShareExistsOperation;

+ (NSString *)accessTokenWithEmail:(NSString *)email password:(NSString *)password;

#pragma mark - Get profile
+ (void)getProfileWithCompletion:(void(^)(NSDictionary* response))completion;

#pragma mark - List directory contents
+ (void)getContentsOfContainer:(Container*)container completion:(void (^)(NSArray* items))completion;
+ (void)getContentsOfTrashWithCompletion:(void (^)(NSArray* items))completion;

#pragma mark - Restore item
+ (void)restoreItem:(Item*)itemToRestore to:(Container*)toItem completion:(void (^)(BOOL success))completion;

#pragma mark - Move item(s)
+ (void)moveItem:(Item*)itemToMove to:(Container*)toItem completion:(void (^)(Item* movedItem))completion;
+ (void)moveItems:(NSArray*)itemsToMove to:(Container*)toItem completion:(void (^)(NSArray* success))completion;

#pragma mark - Delete item(s)
+ (void)deleteItem:(Item*)itemToDelete completion:(void (^)(BOOL success))completion;
+ (void)deleteItems:(NSArray*)items completion:(void (^)(NSArray* results))completion;

#pragma mark - Copy item(s)
+ (void)copyItem:(Item*)itemToCopy to:(Container*)destItem completion:(void (^)(Item* newItem))completion;
+ (void)copyItems:(NSArray*)items to:(Container*)toItem completion:(void (^)(NSArray* success))completion;

#pragma mark - Share item(s)
+ (void)shareItems:(NSArray*)itemsToShare completion:(void (^)(Share* share))completion;
+ (void)listShares:(void (^)(NSArray* shares))completion;
+ (void)browseShare:(Share*) share completion:(void (^)(NSArray* items))completion;
+ (void)addShare:(Share*) share toFolder:(Folder*) folder whenExists:(BCShareExistsOperation) operation completion:(void (^)(bool success))completion;
+ (void)deleteShare:(Share*) share completion:(void (^)(bool success))completion;

#pragma mark - Create new directory
+ (void)createFolderInContainer:(Container*)container withName:(NSString*)name completion:(void (^)(NSDictionary* newFolderDict))completion;

#pragma mark - Downloads
+ (void)downloadItem:(Item*)item delegate:(id <TransferDelegate>)delegate;

#pragma mark - Uploads
+ (void)uploadFile:(NSURL*)sourceURL to:(Folder*)destContainer delegate:(id <TransferDelegate>)delegate;

#pragma mark - Helpers
+ (NSDictionary*)resultDictFromResponseData:(NSData*)data;
@end