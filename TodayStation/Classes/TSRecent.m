//
//  TSRecent.m
//  TodayStation
//
//  Created by Eric Huss on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSRecent.h"

@implementation TSRecent

@synthesize data=_data;

static TSRecent *theSharedRecent = nil;

+ (void)initialize
{
    // initialize may be called for subclasses, hence this check.
    if (self == [TSRecent class]) {
        theSharedRecent = [[self alloc] init];
    }
}

+ (TSRecent *)sharedRecent
{
    return theSharedRecent;
}


- (NSURL *)urlForPlist
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSURL *appSupURL = [manager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (!appSupURL) {
        NSLog(@"Failed to app support directory: %@", [error localizedDescription]);
        return nil;
    }
    NSURL *recentURL = [[appSupURL URLByAppendingPathComponent:bundleID isDirectory:YES] URLByAppendingPathComponent:@"TSRecent.plist"];
    return recentURL;
}

- (void)load
{
    if (self.data == nil) {
        NSURL *recentURL = [self urlForPlist];
        self.data = [NSMutableDictionary dictionaryWithContentsOfURL:recentURL];
        if (self.data == nil) {
            self.data = [NSMutableDictionary dictionaryWithCapacity:10];
        }
    }
}

- (void)save
{
    NSURL *recentURL = [self urlForPlist];
    if (![self.data writeToURL:recentURL atomically:YES]) {
        NSLog(@"Failed to write plist to %@", recentURL);
    }
}

- (NSMutableArray *)arrayForService:(NSString *)service
{
    NSMutableArray *result = [self.data objectForKey:service];
    if (result == nil) {
        result = [NSMutableArray arrayWithCapacity:10];
        [self.data setObject:result forKey:service];
    }
    return result;
}

- (NSMutableArray *)arrayForCurrentService
{
    // XXX: Check current service from settings.
    return [self arrayForService:@"wunderground"];
}

@end
