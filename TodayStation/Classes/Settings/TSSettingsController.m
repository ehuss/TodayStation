//
//  TSSettings.m
//  TodayStation
//
//  Created by Eric Huss on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSSettingsController.h"
#import "TSSelectCityController.h"
#import "TSTempUnitController.h"
#import "TSTimeUnitController.h"
#import "TSColorController.h"

typedef enum {
    TSSettingsTempUnits,
    TSSettings24hour,
    TSSettingsColor,
    TSSettingsChangeLocation,
    TSSettingsMAX,
} TSSettingsRows;

@implementation TSSettingsController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.title = @"Settings";
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return TSSettingsMAX;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = nil;
    if (indexPath.row == TSSettingsChangeLocation) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = @"Change Location";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == TSSettingsTempUnits) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = @"Temperature Units";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
    } else if (indexPath.row == TSSettings24hour) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = @"12/24 Hour Clock";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
    } else if (indexPath.row == TSSettingsColor) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = @"Color Scheme";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == TSSettingsChangeLocation) {
        TSSelectCityController *cityCont = [[TSSelectCityController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:cityCont animated:YES];
    } else if (indexPath.row == TSSettingsTempUnits) {
        TSTempUnitController *tempUnits = [[TSTempUnitController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:tempUnits animated:YES];
    } else if (indexPath.row == TSSettings24hour) {
        TSTimeUnitController *timeUnit = [[TSTimeUnitController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:timeUnit animated:YES];
    } else if (indexPath.row == TSSettingsColor) {
        TSColorController *colorCont = [[TSColorController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:colorCont animated:YES];
    }
}

@end
