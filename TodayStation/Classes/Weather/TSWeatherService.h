//
//  TSWeatherService.h
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TSWeatherController.h"
#import "TSBackgroundService.h"

/*
 This is a background service that periodicially (hourly) fetches
 weather data.  Subclasses should implement doTask to fetch the
 data.  Once that method returns, the delegate is automatically
 called (on the main thread) to indicate that the weather data
 is ready.  The delegate is responsible for calling the build*View
 methods.
 */

@protocol TSWeatherDelegate
    
- (void)weatherReady;
// XXX: weatherError;
// XXX: geo lookup done.
@end

@protocol TSWeatherGeoDelegate

- (void)geoReady;

@end

@interface TSWeatherService : TSBackgroundService

@property (nonatomic, weak) NSObject <TSWeatherDelegate> *delegate;
@property (nonatomic, weak) NSObject <TSWeatherGeoDelegate> *geoDelegate;

// Calls bgGeoLookup via an NSOperation in the background.
- (void)doGeoLookup:(CLLocation *)location;

// Methods subclasses must implement.
- (UIView *)buildForeView;
- (UIView *)buildTallView;
- (UIView *)buildCurrentView;
- (void)bgGeoLookup:(CLLocation *)location;


@end
