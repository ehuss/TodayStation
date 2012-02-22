//
//  TSSelectStationController.m
//  TodayStation
//
//  Created by Eric Huss on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSSelectStationController.h"

@implementation TSSelectStationController

@synthesize locationQuery=_locationQuery;
@synthesize locationResults=_locationResults;
@synthesize airportResults=_airportResults;
@synthesize pwsResults=_pwsResults;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)geoReady
{
    TSWunderground *service = (TSWunderground *)[TSWeatherService sharedWeatherService];
    NSDictionary *queryResults = service.geoData;
    if (queryResults) {
        NSDictionary *location = [queryResults objectForKey:@"location"];
        if (location) {
            // Should check for "type"=="CITY"???
            self.locationResults = location;
            NSDictionary *nws = [location objectForKey:@"nearby_weather_stations"];
            if (nws) {
                NSDictionary *airport = [nws objectForKey:@"airport"];
                if (airport) {
                    self.airportResults = [airport objectForKey:@"station"];
                }
                NSDictionary *pws = [nws objectForKey:@"pws"];
                if (pws) {
                    self.pwsResults = [pws objectForKey:@"station"];
                }
            }
        }
    }
    [self.tableView reloadData];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    TSWunderground *service = (TSWunderground *)[TSWeatherService sharedWeatherService];
    self.title = @"Select a Station";
	self.tableView.scrollEnabled = YES;
    service.geoDelegate = self;
    [service doGeoLookup:self.locationQuery];
    // XXX: Enable bounces zoom?
    // XXX: How to display cancel button?
    
    // XXX: Change search bar autoresizemask to 34?
    //needsDisplayOnBoundsChange = 1
    //separator?
    // XXX: Set tableHeaderView?    
    // XXX: Show busy indicator?
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.locationResults && [self.locationResults objectForKey:@"l"]!=nil) {
        return 3;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Location";
    } else if (section == 1) {
        return @"Airports";
    } else if (section == 2) {
        return @"Personal Weather Stations";
    } else {
        // Unknown section?
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        return 1;
    } else if (section == 1) {
        return [self.airportResults count];
    } else if (section == 2) {
        return [self.pwsResults count];
    } else {
        // Invalid section?
        return 0;
    }
}

- (NSString *)nameForLocation
{
    NSDictionary *l = self.locationResults;
    // City, state always there?
    return [NSString stringWithFormat:@"%@, %@",
                           [l objectForKey:@"city"],
                           [l objectForKey:@"state"]];
}
- (NSString *)nameForAirport:(NSDictionary *)d
{
    return [NSString stringWithFormat:@"%@, %@ (%@)",
                           [d objectForKey:@"city"],
                           [d objectForKey:@"state"],
                           [d objectForKey:@"icao"]];
}
- (NSString *)nameForPws:(NSDictionary *)d
{
    return [d objectForKey:@"neighborhood"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if (indexPath.section == 0 || indexPath.section == 1) {
        cellIdentifier = @"StationCell";
    } else {
        cellIdentifier = @"PWSCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if (indexPath.section == 2) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor darkGrayColor];
            cell.accessoryView = label;
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [self nameForLocation];
    } else if (indexPath.section == 1) {
        NSDictionary *d = [self.airportResults objectAtIndex:indexPath.row];
        cell.textLabel.text = [self nameForAirport:d];
    } else if (indexPath.section == 2) {
        NSDictionary *d = [self.pwsResults objectAtIndex:indexPath.row];
        cell.textLabel.text = [d objectForKey:@"neighborhood"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                     [d objectForKey:@"city"],
                                     [d objectForKey:@"id"]];
        // XXX How to determine mi/km from locale?
        UILabel *label = (UILabel *)cell.accessoryView;
        label.text = [NSString stringWithFormat:@"%@ mi", [d objectForKey:@"distance_mi"]];
        [label sizeToFit];
    } else {
        // Invalid section?
        return nil;
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSRecent *recent = [TSRecent sharedRecent];
    [recent load];
    
    NSString *query;
    if (indexPath.section == 0) {
        query = [self.locationResults objectForKey:@"l"];
        // Strip junk at the beginning.
        if ([[query substringToIndex:3] compare:@"/q/"]==NSOrderedSame) {
            query = [query substringFromIndex:3];
        }
        NSString *name = [self nameForLocation];
        [recent addEntryWithName:name type:@"location" query:query];
    } else if (indexPath.section == 1) {
        NSDictionary *d = [self.airportResults objectAtIndex:indexPath.row];
        query = [d objectForKey:@"icao"];
        NSString *name = [self nameForAirport:d];
        [recent addEntryWithName:name type:@"airport" query:query];
    } else if (indexPath.section == 2) {
        NSDictionary *d = [self.pwsResults objectAtIndex:indexPath.row];
        query = [NSString stringWithFormat:@"pws:%@", [d objectForKey:@"id"]];
        NSString *name = [self nameForPws:d];
        [recent addEntryWithName:name type:@"pws" query:query];
    } else {
        // Unknown section?
        return;
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:query forKey:@"wundergroundQuery"];
    [settings synchronize];
    
    TSWeatherService *service = [TSWeatherService sharedWeatherService];
    [service spawnTaskNow];
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
