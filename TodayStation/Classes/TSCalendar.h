//
//  TSCalendar.h
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "TSBackgroundService.h"

extern NSString *TSCalendarReadyNotification;

@interface TSCalendar : TSBackgroundService

@property (nonatomic, weak) UIView *calendarView;
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) NSCalendar *gregorian;
@property (nonatomic, strong) NSArray *events;

- (id)initWithView:(UIView *)view;
- (void)redrawCalendar;

@end
