//
//  SessionManager.m
//  BitcasaSDK
//
//  Created by Olga on 9/11/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "TransferManager.h"
#import "File.h"
#import "BitcasaAPI.h"

static TransferManager* _sharedManager;
NSString * const kBackgroundSessionIdentifier = @"com.Bitcasa.backgroundSession";

@interface TransferManager ()

@property (nonatomic, strong) NSOperationQueue *backgroundURLQueue;
@property (nonatomic, strong) NSData* lastReceivedData;
@property (nonatomic, strong) NSURLResponse* lastReceivedResponse;

@end

@implementation TransferManager

+ (instancetype)sharedManager
{
    if (_sharedManager)
        return _sharedManager;
    
    static TransferManager *sharedManager = nil;
    dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TransferManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.backgroundURLQueue = [[NSOperationQueue alloc] init];
        [self setupBackgroundURLSessionWithIdentifier:kBackgroundSessionIdentifier];
        
        _sharedManager = self;
    }
    return self;
}

- (void)setupBackgroundURLSessionWithIdentifier:(NSString*)indentifier
{
    if (self.backgroundSession)
    {
        _backgroundSession = [NSURLSession sessionWithConfiguration:_backgroundSession.configuration delegate:self
                                                             delegateQueue:_backgroundURLQueue];
    }
    else
    {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:indentifier];
        sessionConfiguration.discretionary = NO;
        sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        sessionConfiguration.allowsCellularAccess = YES;
        
        _backgroundSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:_backgroundURLQueue];
    }
}

#pragma mark - NSURLSession delegate
- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    if(!originalURL)
        return;
    
    NSURL* destinationUrl = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    
    NSError *errorCopy;
    
    [fileManager removeItemAtURL:destinationUrl error:NULL];
    [fileManager copyItemAtURL:location toURL:destinationUrl error:&errorCopy];

    if ([_delegate respondsToSelector:@selector(itemAtPath:didCompleteDownloadToURL:error:)])
        [_delegate itemAtPath:downloadTask.taskDescription didCompleteDownloadToURL:destinationUrl error:errorCopy];
}

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if ([_delegate respondsToSelector:@selector(itemAtPath:didDownload:outOfTotal:)])
        [_delegate itemAtPath:downloadTask.taskDescription didDownload:totalBytesWritten outOfTotal:totalBytesExpectedToWrite];
}

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // can't resume downloads yet
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error && [_delegate respondsToSelector:@selector(itemAtPath:didCompleteDownloadToURL:error:)])
        [_delegate itemAtPath:task.taskDescription didCompleteDownloadToURL:nil error:error];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    if (session == _backgroundSession)
    {
        _backgroundSession = nil;
        [self setupBackgroundURLSessionWithIdentifier:kBackgroundSessionIdentifier];
    }
}

#pragma mark - NSURLConnectionData delegate
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([_delegate respondsToSelector:@selector(fileAtPath:didUpload:outOfTotal:)])
    {
        NSString* requestURLString = [[connection originalRequest].URL absoluteString];
        [_delegate fileAtPath:requestURLString didUpload:bytesWritten outOfTotal:totalBytesWritten];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self finalizeUploadConnection:connection withError:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self finalizeUploadConnection:connection withError:error];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _lastReceivedResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _lastReceivedData = data;
}

- (void)finalizeUploadConnection:(NSURLConnection *)connection withError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(file:didCompleteUploadWithError:)])
    {
        NSString* parentPath = [[[[connection originalRequest].URL path] componentsSeparatedByString:@"files"] lastObject];
        
        NSDictionary* resultDict = [BitcasaAPI resultDictFromResponseData:_lastReceivedData];
        File* uploadedFile = [[File alloc] initWithDictionary:resultDict andParentPath:parentPath];
        
        [_delegate file:uploadedFile didCompleteUploadWithError:error];
    }
}

@end
