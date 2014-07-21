//
//  TSViewController.h
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSWunderground.h"
#import "TSWeatherController.h"
#import "TSCalendar.h"
#import "TSLocation.h"
#import "TSBusy.h"
#import "TSSelectCityController.h"

@interface TSViewController : UIViewController <TSLocationDelegate,
                                                TSWeatherDelegate,
                                                TSCalendarDelegate>

@property (nonatomic) IBOutlet UILabel *timeView;
@property (nonatomic) IBOutlet UILabel *dateView;
@property (nonatomic) IBOutlet UILabel *secondsView;
@property (nonatomic) IBOutlet UILabel *periodView;
@property (nonatomic) IBOutlet UIView *calendarView;
@property (nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic) TSCalendar *calendar;
@property (nonatomic) NSTimer *secondsTimer;
@property (nonatomic) UIView *currentView;
@property (nonatomic) UIView *tallView;
@property (nonatomic) UIView *foreView;
@property (nonatomic) TSLocation *location;
@property (nonatomic) TSBusy *busy;
@property (nonatomic) TSSelectCityController *selectCityCont;
@property (nonatomic) UINavigationController *selectCityNav;
@property (nonatomic) UINavigationController *settingsNav;
- (void)secondsTick:(NSTimer *)timer;
- (void)updateTime;

@end
