//
//  TSViewController.m
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSSettingsController.h"
#import "TSViewController.h"
#import "TSSettings.h"
#import "TSColors.h"

@implementation TSViewController

@synthesize secondsView=_secondsView;
@synthesize dateView=_dateView;
@synthesize periodView=_periodView;
@synthesize calendarView = _calendarView;
@synthesize settingsButton = _settingsButton;
@synthesize currentView = _currentView;
@synthesize timeView = _timeView;
@synthesize secondsTimer=_secondsTimer;
@synthesize calendar=_calendar;
@synthesize tallView=_tallView;
@synthesize foreView=_foreView;
@synthesize location=_location;
@synthesize busy=_busy;
@synthesize selectCityCont=_selectCityCont;
@synthesize selectCityNav=_selectCityNav;
@synthesize settingsNav=_settingsNav;

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
    if (currentTimeUnit() == TSTime24Hour) {
        [dateFormatter setDateFormat:@"HH:mm"];
        self.timeView.text = [dateFormatter stringFromDate:currentDate];
    } else {
        [dateFormatter setDateFormat:@"h:mm"];
        self.timeView.text = [dateFormatter stringFromDate:currentDate];
    }
    
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

- (void)setColors
{
    TSColor *currentColor = [TSColors theCurrentColor];
    self.view.backgroundColor = currentColor.backgroundColor;
    self.timeView.textColor = currentColor.textColor;
    self.timeView.backgroundColor = currentColor.backgroundColor;
    self.dateView.textColor = currentColor.textColor;
    self.dateView.backgroundColor = currentColor.backgroundColor;
    self.secondsView.textColor = currentColor.textColor;
    self.secondsView.backgroundColor = currentColor.backgroundColor;
    self.periodView.textColor = currentColor.textColor;
    self.periodView.backgroundColor = currentColor.backgroundColor;
    self.calendarView.backgroundColor = currentColor.backgroundColor;
}

- (void)viewDidLoad
{
    [self setColors];
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    TSWeatherService *weatherService = [TSWeatherService sharedWeatherService];
    weatherService.delegate = self;
    [weatherService start];
    
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
    NSString *locationSetting = [settings stringForKey:@"wundergroundQuery"];
    if (locationSetting == nil) {
        // Display a busy indicator while we search for the location.
        if (self.busy == nil) {
            CGRect bf = CGRectMake(0, 200, 500, 100);
            self.busy = [[TSBusy alloc] initWithFrame:bf];            
        }
        self.busy.activityView.color = [TSColors theCurrentColor].textColor;
        self.busy.labelView.text = @"Determining Location...";
        self.busy.labelView.textColor = [TSColors theCurrentColor].textColor;
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

    [self.settingsButton addTarget:self action:@selector(settingsTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsUpdated:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)settingsUpdated:(NSNotification *)notification
{
    // This is a little sloppy.
    [[TSColors sharedColors] configUpdated];
    [self setColors];
    [self weatherReady];
    [self calendarReady];
}

- (void)settingsTouched
{
    TSSettingsController *settingsCont = [[TSSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
    self.settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsCont];
    self.settingsNav.toolbarHidden = NO;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingsDone)];
    settingsCont.toolbarItems = [NSArray arrayWithObjects:item, nil];
    // I would really prefer a smaller (less width) display.
    // However, presentViewController forces a resize of the navigation
    // controller.  I could write my own "present view controller" code, but
    // PageSheet is close enough.
    self.settingsNav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:self.settingsNav animated:YES completion:NULL];
}

- (void)settingsDone
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings synchronize];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)locationNeedsInput
{
    // Display input view for the location (no GPS available).
    
}
- (void)locationConfirm:(CLLocation *)location
{
    // XXX: Cast until generic.
    self.selectCityCont = [[TSSelectCityController alloc] initWithStyle:UITableViewStylePlain];

    self.selectCityNav = [[UINavigationController alloc] initWithRootViewController:self.selectCityCont];

    [self presentViewController:self.selectCityNav
                       animated:NO completion:NULL];

    // Go straight to the station select.
    NSString *query = [NSString stringWithFormat:@"%f,%f",
                       location.coordinate.latitude,
                       location.coordinate.longitude];
    [self.selectCityCont pushStationControllerWithQuery:query];
}

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

    TSWeatherService *service = [TSWeatherService sharedWeatherService];

    self.currentView = [service buildCurrentView];
    self.foreView = [service buildForeView];
    self.tallView = [service buildTallView];

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

- (void)viewDidUnload
{
    [self setTimeView:nil];
    [self setDateView:nil];
    [self setSecondsView:nil];
    [self setPeriodView:nil];
    [self setCurrentView:nil];
    [self setCalendarView:nil];
    [self setSettingsButton:nil];
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

