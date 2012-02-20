//
//  TSViewController.m
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSViewController.h"

@implementation TSViewController

@synthesize secondsView=_secondsView;
@synthesize dateView=_dateView;
@synthesize periodView=_periodView;
@synthesize calendarView = _calendarView;
@synthesize currentView = _currentView;
@synthesize timeView = _timeView;
@synthesize secondsTimer=_secondsTimer;
@synthesize weatherService=_weatherService;
@synthesize calendar=_calendar;
@synthesize tallView=_tallView;
@synthesize foreView=_foreView;
@synthesize location=_location;
@synthesize busy=_busy;
@synthesize searchController=_searchController;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)updateTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // XXX: 24-hour is HH
    [dateFormatter setDateFormat:@"h:mm"];
    self.timeView.text = [dateFormatter stringFromDate:currentDate];
    
    [dateFormatter setDateFormat:@"ss"];
    self.secondsView.text = [dateFormatter stringFromDate:currentDate];
    
    [dateFormatter setDateFormat:@"EEE MMM d"];
    self.dateView.text = [dateFormatter stringFromDate:currentDate];
    
    [dateFormatter setDateFormat:@"a"];
    self.periodView.text = [dateFormatter stringFromDate:currentDate];
    
}

- (void)secondsTick:(NSTimer *)timer
{
    [self updateTime];
}


/*
 - (void)viewDidLoad
 {
 NSLog(@"viewDidLoad %f,%f,%f,%f", self.view.frame.origin.x,
 self.view.frame.origin.y,
 self.view.frame.size.width,
 self.view.frame.size.height);
 }
 
 - (void)viewWillAppear:(BOOL)animated
 {
 NSLog(@"viewWillAppear %f,%f,%f,%f", self.view.frame.origin.x,
 self.view.frame.origin.y,
 self.view.frame.size.width,
 self.view.frame.size.height);
 }
 */

- (void)viewDidAppear:(BOOL)animated
{
    if (self.weatherService == nil) {        
        self.weatherService = [[TSWunderground alloc] init];
        self.weatherService.delegate = self;
        // XXX DEBUGGING LOCATION
//        [self.weatherService start];
    }
    
    if (self.secondsTimer == nil) {
        [self updateTime];
        self.secondsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secondsTick:) userInfo:nil repeats:YES];
    }
    
    if (self.calendar == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarUpdated:) name:EKEventStoreChangedNotification object:nil];
        self.calendar = [[TSCalendar alloc] initWithView:self.calendarView];
        self.calendar.delegate = self;
        [self.calendar start];
    }

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *locationSetting = [settings stringForKey:@"location"];
    if (locationSetting == nil) {
        // Display a busy indicator while we search for the location.
        if (self.busy == nil) {
            CGRect bf = CGRectMake(0, 200, 500, 100);
            self.busy = [[TSBusy alloc] initWithFrame:bf];            
        }
        self.busy.activityView.color = [UIColor whiteColor];
        self.busy.labelView.text = @"Determining Location...";
        self.busy.labelView.textColor = [UIColor whiteColor];
        self.busy.labelView.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
        [self.busy.activityView startAnimating];
        [self.view addSubview:self.busy.container];
        if (self.location == nil) {
            self.location = [[TSLocation alloc] init];
            self.location.delegate = self;
        }

        // Start location search.
        [self.location getLocation];
    }

}

- (void)locationNeedsInput
{
    // Display input view for the location.
}
- (void)locationConfirm:(CLLocation *)location
{
    // Do a geo lookup with lat/long to get more detail.
//    [self.weatherService doGeoLookup:location];
    
    self.searchController = [[TSLocationSearchController alloc] initWithStyle:UITableViewStylePlain];
    self.searchController.source = [[TSWundergroundLocationSource alloc] init];
    self.searchController.source.weatherService = self.weatherService;
    self.searchController.source.tableController = self.searchController;
    [self.searchController.source setInitialLocation:location];
    [self presentViewController:self.searchController animated:YES completion:NULL];    
}
/*    // Display alert confirming location.
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Is this your location?" message:[location description] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView
            clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clicked %i", buttonIndex);
}*/


- (void)calendarUpdated:(NSNotification *)notification
{
    NSLog(@"Calendar updated.");
    [self.calendar spawnTaskNow];
}

- (void)calendarReady
{
    NSLog(@"Calendar redraw.");
    [self.calendar redrawCalendar];    
}

- (void)weatherReady
{
    NSLog(@"Weather updated.");
    [self.currentView removeFromSuperview];
    [self.foreView removeFromSuperview];
    [self.tallView removeFromSuperview];
    
    self.currentView = [self.weatherService buildCurrentView];
    self.foreView = [self.weatherService buildForeView];
    self.tallView = [self.weatherService buildTallView];

    [self.view addSubview:self.currentView];
    [self.view addSubview:self.foreView];
    [self.view addSubview:self.tallView];
}

/*
 - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
 {
 NSLog(@"willRotateToInterfaceOrientation %f,%f,%f,%f", self.view.frame.origin.x,
 self.view.frame.origin.y,
 self.view.frame.size.width,
 self.view.frame.size.height);
 }
 
 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
 {
 NSLog(@"didRotateFromInterfaceOrientation %f,%f,%f,%f", self.view.frame.origin.x,
 self.view.frame.origin.y,
 self.view.frame.size.width,
 self.view.frame.size.height);
 }*/

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [self setTimeView:nil];
    [self setDateView:nil];
    [self setSecondsView:nil];
    [self setPeriodView:nil];
    [self setCurrentView:nil];
    [self setCalendarView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

