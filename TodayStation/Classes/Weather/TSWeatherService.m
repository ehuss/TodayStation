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

- (void)geoLookupWrapper:(CLLocation *)location
{
    [self bgGeoLookup:location];
    [self.geoDelegate performSelectorOnMainThread:@selector(geoReady) withObject:nil waitUntilDone:NO];
}

- (void)doGeoLookup:(CLLocation *)location
{
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(geoLookupWrapper:) object:location];
    [[NSOperationQueue currentQueue] addOperation:op];    
}


- (void)bgGeoLookup:(CLLocation *)location
{
    return;
}

@end
