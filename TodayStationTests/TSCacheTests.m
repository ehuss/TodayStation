//
//  TSCacheTests.m
//  Today Station
//
//  Created by Eric Huss on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSCacheTests.h"
#import "TSCache.h"

@implementation TSCacheTests

- (void)setUp
{
    [super setUp];
    
    TSCache *cache = [[TSCache alloc] init];
    NSURL *dir = cache.cacheDir;
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtURL:dir error:nil];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testLoadPlist
{    
    TSCache *cache = [[TSCache alloc] init];
    [cache loadPlist];
    NSMutableDictionary *plist = cache.plist;
    NSMutableDictionary *caches = [plist objectForKey:@"TSCaches"];
    STAssertNotNil(caches, @"Caches was nil.");
    STAssertEquals([caches count], 0U, @"len(caches)!=0");
}

- (void)testEncache
{
    TSCache *cache = [[TSCache alloc] init];
    NSData *data = [NSData dataWithBytes:"TEST" length:4];
    // Encache.
    [cache encacheData:data name:@"test1" mustMatch:@"1234" forTime:5];

    // Test fetch.
    data = [cache getForName:@"test1" withMatch:@"1234"];
    STAssertNotNil(data, @"Couldn't fetch");
    const void *bytes = [data bytes];
    STAssertEquals(memcmp(bytes, "TEST", 4) , 0, @"Data didn't match");

    // Verify plist.
    NSMutableDictionary *plist = cache.plist;
    NSMutableDictionary *caches = [plist objectForKey:@"TSCaches"];
    STAssertNotNil(caches, @"Caches was nil.");
    STAssertEquals([caches count], 1U, @"len(caches)!=1");
    // Verify 1 file in dir.
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *files = [manager contentsOfDirectoryAtURL:cache.cacheDir includingPropertiesForKeys:[NSArray array] options:0 error:&error];
    STAssertEquals([files count], 2U, @"Len(files)!=1");
    
    // Test for expiration.
    sleep(5);
    data = [cache getForName:@"test1" withMatch:@"1234"];
    STAssertNil(data, @"Cache didn't expire.");
    // Make sure it cleaned up.
    plist = cache.plist;
    caches = [plist objectForKey:@"TSCaches"];
    STAssertNotNil(caches, @"Caches was nil.");
    STAssertEquals([caches count], 0U, @"len(caches)!=0");
    files = [manager contentsOfDirectoryAtURL:cache.cacheDir includingPropertiesForKeys:[NSArray array] options:0 error:&error];
    STAssertEquals([files count], 1U, @"Len(files)!=1");
}

- (void)testMatch
{
    TSCache *cache = [[TSCache alloc] init];
    NSData *data = [NSData dataWithBytes:"TEST2" length:5];
    // Encache.
    [cache encacheData:data name:@"test1" mustMatch:@"1234" forTime:5];
    
    // Check good match.
    data = [cache getForName:@"test1" withMatch:@"1234"];
    STAssertNotNil(data, @"Couldn't fetch");
    const void *bytes = [data bytes];
    STAssertEquals(memcmp(bytes, "TEST2", 5) , 0, @"Data didn't match");

    // Check bad match.
    data = [cache getForName:@"test1" withMatch:@"12345"];
    STAssertNil(data, @"Didn't clear");
}


@end
