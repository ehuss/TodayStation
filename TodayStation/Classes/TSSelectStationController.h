//
//  TSSelectStationController.h
//  TodayStation
//
//  Created by Eric Huss on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
// XXX Make service generic.
#import "TSWunderground.h"
#import "TSRecent.h"

@interface TSSelectStationController : UITableViewController <TSWeatherGeoDelegate>

@property (nonatomic, weak) TSWunderground *service;
@property (nonatomic, copy) NSString *locationQuery;

// Results objects set once geo data is available
// (via geoReady).
@property (nonatomic, strong) NSDictionary *locationResults;
@property (nonatomic, strong) NSArray *airportResults;
@property (nonatomic, strong) NSArray *pwsResults;

- (id)initWithStyle:(UITableViewStyle)style service:(TSWunderground *)service;
@end
