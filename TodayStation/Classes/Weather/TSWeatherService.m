//
//  TSWeatherService.m
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSWeatherService.h"

@implementation TSWeatherService
@synthesize delegate =_delegate;
@synthesize geoDelegate=_geoDelegate;

- (UIView *)buildForeView
{
    return nil;
}

- (UIView *)buildTallView
{
    return nil;
}

- (UIView *)buildCurrentView
{
    return nil;
}

- (void)geoLookupWrapper:(NSString *)query
{
    [self bgGeoLookup:query];
    [self.geoDelegate performSelectorOnMainThread:@selector(geoReady) withObject:nil waitUntilDone:NO];
}

- (void)doGeoLookup:(NSString *)query
{
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(geoLookupWrapper:) object:query];
    [[NSOperationQueue currentQueue] addOperation:op];    
}


- (void)bgGeoLookup:(NSString *)query
{
    return;
}

@end
