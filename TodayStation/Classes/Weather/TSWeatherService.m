//
//  TSWeatherService.m
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSWeatherService.h"

NSString *TSWeatherReadyNotification = @"TSWeatherReadyNotification";

@implementation TSWeatherService

- (id)init
{
    if (self = [super init]) {
        self.notificationName = TSWeatherReadyNotification;
        return self;
    }
    return nil;
}


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

@end
