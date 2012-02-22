//
//  TSSelectCityController.m
//  TodayStation
//
//  Created by Eric Huss on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSSelectCityController.h"
#import "TSSelectStationController.h"

@implementation TSSelectCityController

@synthesize searchCont=_searchCont;
@synthesize recent=_recent;
@synthesize searchResults=_searchResults;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.searchResults = [NSArray array];
    self.title = @"Select a City";
	self.tableView.scrollEnabled = YES;
    // XXX: Enable bounces zoom?
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchBar.showsCancelButton = YES;
    // XXX: Change search bar autoresizemask to 34?
    //needsDisplayOnBoundsChange = 1
    //separator?
    [searchBar sizeToFit];
    searchBar.delegate = self;
    searchBar.placeholder = @"Enter City, State or Zip";
    searchBar.showsCancelButton = YES;
    self.tableView.tableHeaderView = searchBar;
    
    // This implicitly sets self.searchDispayController.
    self.searchCont = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchCont.delegate = self;
    self.searchCont.searchResultsDataSource = self;
    self.searchCont.searchResultsDelegate = self;
    // XXX: Set searchResultsTitle?

    self.recent = [TSRecent sharedRecent];
    [self.recent load];

    
    [self.tableView reloadData];
    [super viewDidLoad];
    
    // XXX: Call search controller set active if count==0.

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
    NSLog(@"View did appear.");
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

#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView
        numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        NSArray *data = [self.recent arrayForCurrentService];
        return [data count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
    NSMutableArray *data = [self.recent arrayForCurrentService];
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        // SEARCHING
        NSDictionary *result = [self.searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = [result objectForKey:@"name"];
    }
	else {
        NSDictionary *entry = [data objectAtIndex:indexPath.row];
        cell.textLabel.text = [entry objectForKey:@"name"];
    }
	
	return cell;
}

- (void)pushStationControllerWithQuery:(NSString *)query
{
    TSSelectStationController *controller = [[TSSelectStationController alloc] initWithStyle:UITableViewStylePlain];
    controller.locationQuery = query;
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //SELECTED!!
    // For some reason, the WillEndSearch method does not get
    // called in this case.
    // XXX Cast.
    TSWunderground *service = (TSWunderground *)[TSWeatherService sharedWeatherService];
    [service stopAutocompletePoller];

    
    /*
	 If the requesting table view is the search display controller's table view, configure the next view controller using the filtered content, otherwise use the main list.
	 */

    NSString *query;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *entry = [self.searchResults objectAtIndex:indexPath.row];
        query = [NSString stringWithFormat:@"zmw:%@", [entry objectForKey:@"zmw"]];
    } else {
        NSDictionary *entry = [[self.recent arrayForCurrentService] objectAtIndex:indexPath.row];
        query = [entry objectForKey:@"id"];
    }
    
    [self pushStationControllerWithQuery:query];
    
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    // XXX: cast
    TSWunderground *service = (TSWunderground *)[TSWeatherService sharedWeatherService];
    [service startAutocompletePollerOnDelegate:self];    
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    // XXX: cast
    TSWunderground *service = (TSWunderground *)[TSWeatherService sharedWeatherService];
    [service stopAutocompletePoller];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // SEARCH STRING ENTERED
    /*
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];*/
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

- (NSString *)getCurrentSearchString
{
    return self.searchCont.searchBar.text;
}

- (void)setResultsForAutocomplete:(NSArray *)results
{
    self.searchResults = results;
    [self.searchCont.searchResultsTableView reloadData];
}


@end
