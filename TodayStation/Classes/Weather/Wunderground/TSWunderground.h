//
//  TSWunderground.h
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSWeatherService.h"
#import "TSWundergroundController.h"

@protocol TSWundergroundAutoDelegate

- (NSString *)getCurrentSearchString;
- (void)setResultsForAutocomplete:(NSArray *)results;

@end

@interface TSWunderground : TSWeatherService

// Data holds the last weather query.
@property (atomic, strong) NSDictionary *data;
@property (nonatomic, strong) TSWundergroundController *controller;

// Geo data is used for looking up stations.
@property (nonatomic, strong) NSDictionary *geoData;

// Autocomplete properties.
@property (nonatomic, weak) NSObject <TSWundergroundAutoDelegate>*autocompleteDelegate;
@property (atomic, strong) NSOperation *autocompleteOp;
@property (nonatomic, strong) NSTimer *autocompleteTimer;
@property (nonatomic, copy) NSString *lastAutocomplete;
@property (nonatomic, assign) BOOL isDaylight;

- (void)startAutocompletePollerOnDelegate:(NSObject <TSWundergroundAutoDelegate>*)delegate;
- (void)stopAutocompletePoller;
@end
