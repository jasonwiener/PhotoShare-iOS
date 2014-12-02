//
//  BCFileTransferService.h
//  PhotoShare
//
//  Created by Nalinda Somasundara on 11/5/14.
//
//

#import <Foundation/Foundation.h>
#import <BitcasaSDK/BitcasaAPI.h>
@class BCFileTransfer;

@interface BCFileTransferService : NSObject <TransferDelegate>

- (void)addFileTransferReference:(BCFileTransfer *)fileTransfer forFilename:(NSString *)filename;

@end
