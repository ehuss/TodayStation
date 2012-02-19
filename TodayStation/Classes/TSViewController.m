//
//  TSController.m
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSViewController.h"
#import "TSWunderground.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherUpdated:) name:TSWeatherReadyNotification object:nil];
        self.weatherService = [[TSWunderground alloc] init];
        [self.weatherService start];
    }
    
    if (self.secondsTimer == nil) {
        [self updateTime];
        self.secondsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secondsTick:) userInfo:nil repeats:YES];
    }
    
    if (self.calendar == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarRedraw:) name:TSCalendarReadyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarUpdated:) name:EKEventStoreChangedNotification object:nil];
        self.calendar = [[TSCalendar alloc] initWithView:self.calendarView];
        [self.calendar start];
    }
}

- (void)calendarUpdated:(NSNotification *)notification
{
    NSLog(@"Calendar updated.");
    [self.calendar spawnTaskNow];
}

- (void)calendarRedraw:(NSNotification *)notification
{
    NSLog(@"Calendar redraw.");
    [self.calendar redrawCalendar];    
}

- (void)weatherUpdated:(NSNotification *)notification
{
    NSLog(@"Weather updated.");
    UIView *currentView = [self.weatherService buildCurrentView];
    UIView *foreView = [self.weatherService buildForeView];
    UIView *tallView = [self.weatherService buildTallView];
    // XXXXXXX HANDLE REPLACEMENT.
    /*    for (UIView *view in self.currentView.subviews) {
     [view removeFromSuperview];
     }*/
    [self.view addSubview:currentView];
//    [self.view addSubview:tallView];
    [self.view addSubview:foreView];
    [self.view addSubview:tallView];
    
    
    
    
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

