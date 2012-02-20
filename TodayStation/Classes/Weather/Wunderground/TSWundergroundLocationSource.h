//
//  TSWundergroundLocationSource.h
//  TodayStation
//
//  Created by Eric Huss on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSWeatherService.h"
#import "TSWunderground.h"

@interface TSWundergroundEntry : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *locationId;
@end

@interface TSWundergroundSection : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *entries;
@end

@interface TSWundergroundLocationSource : NSObject <UITableViewDataSource, TSWeatherGeoDelegate>

// Array of TSWundergroundSections.
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, weak) TSWunderground *weatherService;
@property (nonatomic, weak) UITableViewController *tableController;

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier;

- (void)setInitialLocation:(CLLocation *)location;
@end
