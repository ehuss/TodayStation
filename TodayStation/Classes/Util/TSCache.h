//
//  TSCache.h
//  TodayStation
//
//  Created by Eric Huss on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 TODO:
 - Clear expired in directory at startup.
 */

#import <Foundation/Foundation.h>

@interface TSCache : NSObject

@property (nonatomic, strong) NSURL *cacheDir;
@property (nonatomic, strong) NSURL *plistURL;
@property (nonatomic, strong) NSMutableDictionary *plist;

+ (TSCache *)sharedCache;

- (void)encacheData:(NSData *)data 
               name:(NSString *)name
          mustMatch:(NSString *)match
            forTime:(NSTimeInterval)seconds;

- (NSData *)getForName:(NSString *)name
             withMatch:(NSString *)match;

// Private
- (void)loadPlist;

@end
