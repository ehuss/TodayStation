//
//  TSWundergroundLocationSource.m
//  TodayStation
//
//  Created by Eric Huss on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSWundergroundLocationSource.h"

@implementation TSWundergroundEntry
@synthesize text=_text;
@synthesize locationId=_locationId;
@end

@implementation TSWundergroundSection
@synthesize name=_name;
@synthesize entries=_entries;
@end

#define LABEL_TAG 1

@implementation TSWundergroundLocationSource

@synthesize sections=_sections;
@synthesize weatherService=_weatherService;
@synthesize tableController=_tableController;

- (void)setInitialLocation:(CLLocation *)location
{
    // In background, ask weather service to look up entries that match
    // or are close to these coordinates.
    self.weatherService.geoDelegate = self;
    [self.weatherService doGeoLookup:location];
}

- (void)geoReady
{
    // Build the data from the dictionary in the weather service.
    TSWundergroundSection *section;
    TSWundergroundEntry *entry;
    
    self.sections = [NSMutableArray arrayWithCapacity:5];
    // The single-match location.
    section = [[TSWundergroundSection alloc] init];
    section.name = @"Location";
    entry = [[TSWundergroundEntry alloc] init];
    NSDictionary *geoData = self.weatherService.geoData;
    NSDictionary *location = [geoData objectForKey:@"location"];
    // XXX: Check for nil.  Check for "type"=="CITY".
    entry.text = [NSString stringWithFormat:@"%@, %@, %@",
                  [location objectForKey:@"city"],
                  [location objectForKey:@"state"],
                  [location objectForKey:@"country_name"]];
    entry.locationId = [geoData objectForKey:@"l"];
    section.entries = [NSArray arrayWithObjects:entry, nil];
    [self.sections addObject:section];
    
    // The nearby airports.
    NSDictionary *stations = [location objectForKey:@"nearby_weather_stations"];
    NSArray *airports = [[stations objectForKey:@"airport"] objectForKey:@"station"];
    if (airports != nil && [airports count]) {
        section = [[TSWundergroundSection alloc] init];
        section.name = @"Airports";
        section.entries = [NSMutableArray arrayWithCapacity:[airports count]];
        for (NSDictionary *station in airports) {
            entry = [[TSWundergroundEntry alloc] init];
            entry.text = [NSString stringWithFormat:@"Airport:%@\n%@. %@",
                          [station objectForKey:@"icao"],
                          [station objectForKey:@"city"],
                          [station objectForKey:@"state"]];
            entry.locationId = [station objectForKey:@"icao"];
            [section.entries addObject:entry];
        }
        [self.sections addObject:section];
    }
    
    // The nearby personal stations.
    NSArray *pws = [[stations objectForKey:@"pws"] objectForKey:@"station"];
    if (pws != nil && [pws count]) {
        section = [[TSWundergroundSection alloc] init];
        section.name = @"Personal Weather Stations";
        section.entries = [NSMutableArray arrayWithCapacity:[pws count]];
        for (NSDictionary *station in pws) {
            entry = [[TSWundergroundEntry alloc] init];
            entry.text = [NSString stringWithFormat:@"%@, %@, %@\nDistance: %@km/%@mi",
                          [station objectForKey:@"neighborhood"],
                          [station objectForKey:@"city"],
                          [station objectForKey:@"state"],
                          [station objectForKey:@"distance_km"],
                          [station objectForKey:@"distance_mi"]];
            entry.locationId = [NSString stringWithFormat:@"pws:%@", 
                                [station objectForKey:@"id"]];
            [section.entries addObject:entry];
        }
        [self.sections addObject:section];        
    }
    
    [self.tableController.tableView reloadData];
}

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

    // XXX Size?
    CGRect labelSize=CGRectMake(0, 0, 800, 50);
    UILabel *label = [[UILabel alloc] initWithFrame:labelSize];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    label.tag = LABEL_TAG;
    [cell.contentView addSubview:label];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"TSWundergroundLocation";
    
    TSWundergroundSection *wunderSec = [self.sections objectAtIndex:indexPath.section];
    TSWundergroundEntry *entry = [wunderSec.entries objectAtIndex:indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
	}
    
    UILabel *label = (UILabel *)[cell viewWithTag:LABEL_TAG];
    label.text = entry.text;
	
	return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TSWundergroundSection *wunderSec = [self.sections objectAtIndex:section];
    return [wunderSec.entries count];
}

- (NSString *)tableView:(UITableView *)tableView
            titleForHeaderInSection:(NSInteger)section
{
    TSWundergroundSection *wunderSec = [self.sections objectAtIndex:section];
    return wunderSec.name;
}

@end
