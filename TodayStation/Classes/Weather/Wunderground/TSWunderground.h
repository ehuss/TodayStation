//
//  TSWunderground.h
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSWeatherService.h"
#import "TSWundergroundController.h"

@interface TSWunderground : TSWeatherService <NSXMLParserDelegate>

@property (atomic, strong) NSDictionary *data;
@property (nonatomic, strong) TSWundergroundController *controller;
@property (nonatomic, strong) NSDictionary *geoData;

- (void)fetchData;

@end
