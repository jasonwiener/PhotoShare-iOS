//
//  BCPlistReader.h
//  PhotoShare
//
//  Created by Chathurka on 10/23/14.
//
//

#import <Foundation/Foundation.h>

@interface BCPlistReader : NSObject

/**
 *  Inisialization with Plist File name.
 *
 *  @param fileName Plist File name
 
 *  @return BCPlistReader type object
 */

- (instancetype)initWithFileName:(NSString *) fileName NS_DESIGNATED_INITIALIZER;


/**
 *  Get App config plist value for key.
 *
 *  @param key Plist key.
 *
 *  @return Value for key
 */

- (id)appConfigValueForKey:(NSString *)key;

@end
