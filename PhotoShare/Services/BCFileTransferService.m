//
//  BCFileTransferService.m
//  PhotoShare
//
//  Created by Nalinda Somasundara on 11/5/14.
//
//

#import <BitcasaSDK/File.h>
#import "BCFileTransferService.h"
#import "BCFileTransfer.h"

@implementation BCFileTransferService
{
    NSMutableDictionary *_transfers;
}

- (instancetype)init
{
    if (self = [super init]) {
        _transfers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)addFileTransferReference:(BCFileTransfer *)fileTransfer forFilename:(NSString *)filename
{
    _transfers[filename] = fileTransfer;
    if (fileTransfer.filename == nil) {
        fileTransfer.filename = filename;
    }
}

#pragma mark - Transfer Delegate Methods
// Upload completion
- (void)file:(File *)file didCompleteUploadWithError:(NSError *)err
{
    BCFileTransfer *fileTransfer = _transfers[file.name];
    
    if (fileTransfer) {
        if (fileTransfer.uploadCompletion) {
            [_transfers removeObjectForKey:file.name];
            fileTransfer.uploadCompletion(file, fileTransfer.filename, fileTransfer.referenceObject, err);
        }
    }
}

// Download completion
- (void)itemAtPath:(NSString *)itemPath didCompleteDownloadToURL:(NSURL *)locationURL error:(NSError *)err
{
    NSString *filename = [locationURL lastPathComponent];
    
    BCFileTransfer *fileTransfer = _transfers[filename];
    
    if (fileTransfer) {
        if (fileTransfer.downloadCompletion) {
            [_transfers removeObjectForKey:filename];
            fileTransfer.downloadCompletion(fileTransfer.filename, fileTransfer.referenceObject, locationURL, err);
        }
    }
}

@end
