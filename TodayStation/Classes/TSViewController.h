//
//  TSViewController.h
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSWunderground.h"
#import "TSWeatherService.h"
#import "TSWeatherController.h"
#import "TSCalendar.h"
#import "TSLocation.h"
#import "TSBusy.h"
#import "TSLocationSearchController.h"

@interface TSViewController : UIViewController <TSLocationDelegate,
                                                TSWeatherDelegate,
                                                TSCalendarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UILabel *dateView;
@property (weak, nonatomic) IBOutlet UILabel *secondsView;
@property (weak, nonatomic) IBOutlet UILabel *periodView;
@property (weak, nonatomic) IBOutlet UIView *calendarView;
@property (strong, nonatomic) TSCalendar *calendar;
@property (nonatomic, strong) NSTimer *secondsTimer;
@property (nonatomic, strong) TSWeatherService *weatherService;
@property (weak, nonatomic) UIView *currentView;
@property (nonatomic, weak) UIView *tallView;
@property (nonatomic, weak) UIView *foreView;
@property (nonatomic, strong) TSLocation *location;
@property (nonatomic, strong) TSBusy *busy;
@property (nonatomic, strong) TSLocationSearchController *searchController;

- (void)secondsTick:(NSTimer *)timer;
- (void)updateTime;

@end
