//
//  TSCache.m
//  TodayStation
//
//  Created by Eric Huss on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSCache.h"

@implementation TSCache

@synthesize plist=_plist;
@synthesize cacheDir=_cacheDir;
@synthesize plistURL=_plistURL;

static TSCache *theSharedCache = nil;

+ (void)initialize
{
    // initialize may be called for subclasses, hence this check.
    if (self == [TSCache class]) {
        theSharedCache = [[self alloc] init];
    }
}

+ (TSCache *)sharedCache
{
    return theSharedCache;
}

- (NSURL *)cacheDir
{
    if (_cacheDir != nil) {
        return _cacheDir;
    }
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSURL *cachesURL = [manager URLForDirectory:NSCachesDirectory
                                       inDomain:NSUserDomainMask
                              appropriateForURL:nil
                                         create:YES
                                          error:&error];
    if (!cachesURL) {
        NSLog(@"Failed to caches directory: %@", [error localizedDescription]);
        return nil;
    }
    _cacheDir = [[cachesURL URLByAppendingPathComponent:bundleID
                                           isDirectory:YES] URLByAppendingPathComponent:@"TSCache" isDirectory:YES];
    
    if (![manager createDirectoryAtURL:_cacheDir withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create caches dir: %@", [error localizedDescription]);
    }
    return _cacheDir;
}

- (NSURL *)plistURL
{
    if (_plistURL != nil) {
        return _plistURL;
    }
    _plistURL = [self.cacheDir URLByAppendingPathComponent:@"TSCache.plist"];
    return _plistURL;
}

- (void)loadPlist
{
    if (self.plist != nil) {
        return;
    }
    self.plist = [NSMutableDictionary dictionaryWithContentsOfURL:self.plistURL];
    if (self.plist == nil) {
        self.plist = [NSMutableDictionary dictionaryWithCapacity:10];
        [self.plist setObject:[NSMutableDictionary dictionaryWithCapacity:10] forKey:@"TSCaches"];
        
    }
    
}

- (void)savePlist
{
    [self.plist writeToURL:self.plistURL atomically:YES];
}

- (void)removeEntry:(NSString *)name
{
    NSMutableDictionary *caches = [self.plist objectForKey:@"TSCaches"];
    [caches removeObjectForKey:name];
    [self savePlist];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *itemURL = [self.cacheDir URLByAppendingPathComponent:name];
    [manager removeItemAtURL:itemURL error:nil];    
}

- (void)encacheData:(NSData *)data 
               name:(NSString *)name
          mustMatch:(NSString *)match
            forTime:(NSTimeInterval)seconds;
{
    [self loadPlist];
    NSURL *itemURL = [self.cacheDir URLByAppendingPathComponent:name];
    NSError *error;
    if([data writeToURL:itemURL options:NSDataWritingAtomic error:&error] == NO) {
        NSLog(@"Failed to write data to cache: %@", [error localizedDescription]);
        return;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
    [info setObject:expireDate forKey:@"TSExpireDate"];
    [info setObject:match forKey:@"TSMustMatch"];
    NSMutableDictionary *caches = [self.plist objectForKey:@"TSCaches"];
    [caches setObject:info forKey:name];
    [self savePlist];
}

- (NSData *)getForName:(NSString *)name
             withMatch:(NSString *)match;
{
    [self loadPlist];
    NSMutableDictionary *caches = [self.plist objectForKey:@"TSCaches"];
    NSMutableDictionary *entry = [caches objectForKey:name];
    if (entry == nil) {
        return nil;
    }
    NSDate *expireDate = [entry objectForKey:@"TSExpireDate"];
    NSString *eMatch = [entry objectForKey:@"TSMustMatch"];
    if ([expireDate timeIntervalSinceNow] < 0 ||
        [eMatch compare:match] != NSOrderedSame) {
        [self removeEntry:name];        
        return nil;
    }
    NSURL *itemURL = [self.cacheDir URLByAppendingPathComponent:name];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[itemURL path]]) {
        return [NSData dataWithContentsOfURL:itemURL];
    } else {
        // Odd, file missing.
        [self removeEntry:name];
        return nil;
    }
}


@end
