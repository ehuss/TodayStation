//
//  TSCalendar.m
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TSCalendar.h"
#import "TSUtil.h"
#import "TSLabel.h"

const static NSUInteger dateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
const static NSUInteger dateTimeFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;

const static CGRect itemRect = { .origin.x = 10,
                                 .origin.y = 0,
                                 .size.width = 490,
                                 .size.height = 38
};

NSString *TSCalendarReadyNotification = @"TSCalendarReadyNotification";

@implementation TSCalendar

@synthesize calendarView=_calendarView;
@synthesize eventStore=_eventStore;
@synthesize gregorian=_gregorian;
@synthesize events=_events;

- (id)initWithView:(UIView *)view
{
    if (self = [super init]) {
        _gregorian = [[NSCalendar alloc]
                      initWithCalendarIdentifier:NSGregorianCalendar];
        _calendarView = view;
        self.notificationName = TSCalendarReadyNotification;
        // This probably isn't necessary, since we receive notifications.
        // However, I feel it's better to be on the safe side in case we
        // miss a notification for some reason.
        updateInterval = 5*60;

        return self;
    }
    return nil;
}

- (NSDate *)todayStart
{
    NSDate *today = [NSDate date];
    NSDateComponents *components = [_gregorian components:dateFlags fromDate:today];
    return [_gregorian dateFromComponents:components];     
}

- (BOOL)sameDay:(NSDate *)date1 to:(NSDate *)date2
{
    NSDateComponents *comp1 = [_gregorian components:dateFlags fromDate:date1];
    NSDateComponents *comp2 = [_gregorian components:dateFlags fromDate:date2];
    return comp1.year==comp2.year && comp1.month==comp2.month && comp1.day==comp2.day;
}

- (NSDate *)endDateFrom:(NSDate *)date
{
    return [NSDate dateWithTimeInterval:60*60*24*7 sinceDate:date];
}

- (BOOL)dateIsTomorrow:(NSDate *)date
{
    // Probably has rare issues with DST.
    NSDate *tomorrow = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    return [self sameDay:date to:tomorrow];
}

- (TSLabel *)getLabelWithBg:(BOOL)bg
{
    TSLabel *view = [[TSLabel alloc] initWithFrame:itemRect];
    view.backgroundColor = [UIColor clearColor];
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont fontWithName:@"HelveticaNeue" size:32];
    view.text = @"test";
    view.layer.cornerRadius = 8;

    if (bg) {
        view.gradient = [NSArray arrayWithObjects:(id)[UIColor darkGrayColor].CGColor,
                         (id)[UIColor blackColor].CGColor,
                         nil];
        view.textRect = CGRectOffset(itemRect, 5, 0);
    }    
    
    return view;
}

- (UIView *)dateHeaderViewFor:(NSDate *)date
{
    NSString *datePrefix;
    if ([self sameDay:date to:[NSDate date]]) {
        datePrefix = @"Today ";
    } else if ([self dateIsTomorrow:date]) {
        datePrefix = @"Tomorrow ";
    } else {
        datePrefix = @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"E MMM d"];
    NSString *dateText = [formatter stringFromDate:date];
    
    TSLabel *view = [self getLabelWithBg:YES];
    view.text = [NSString stringWithFormat:@"%@%@", datePrefix,dateText];
    return view;
}

- (void)moveView:(UIView *)view down:(NSUInteger)count
{
    view.frame = CGRectMake(view.frame.origin.x,
                            view.frame.origin.y + count*view.frame.size.height,
                            view.frame.size.width,
                            view.frame.size.height);
    
}

- (UIView *)viewForEvent:(EKEvent *)event
{
    TSLabel *label = [self getLabelWithBg:NO];
    label.textRect = CGRectOffset(itemRect, 10, 0);
    if (event.allDay) {
        label.text = event.title;
    } else {
        NSString *time;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        if (is24h) {
            [formatter setDateFormat:@"HH:mm"];
        } else {
            NSDateComponents *comp = [_gregorian components:dateTimeFlags fromDate:event.startDate];
            if (comp.minute == 0) {
                [formatter setDateFormat:@"ha"];                            
            } else {
                [formatter setDateFormat:@"h:mma"];            
            }
        }
        time = [[formatter stringFromDate:event.startDate] lowercaseString];
        
        label.text = [NSString stringWithFormat:@"%@ %@",
                      time, event.title];
    }
    return label;
}

- (NSArray *)getEvents
{
#if TARGET_IPHONE_SIMULATOR
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:10];
    EKEvent *event;
    NSDate *date;
    NSDateComponents *components;
    
    event = [EKEvent eventWithEventStore:self.eventStore];
    date = [NSDate dateWithTimeIntervalSinceNow:60*60];
    components = [_gregorian components:dateTimeFlags fromDate:date];
    components.minute = 0;
    date = [_gregorian dateFromComponents:components];     
    event.startDate = date;
    event.title = @"Sample event 1.";
    [events addObject:event];
    
    event = [EKEvent eventWithEventStore:self.eventStore];
    date = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    components = [_gregorian components:dateTimeFlags fromDate:date];
    components.minute = 30;
    date = [_gregorian dateFromComponents:components];     
    event.startDate = date;
    event.title = @"Sample event 2.";
    [events addObject:event];
    
    event = [EKEvent eventWithEventStore:self.eventStore];
    date = [NSDate dateWithTimeIntervalSinceNow:60*60*24*2];
    components = [_gregorian components:dateTimeFlags fromDate:date];
    components.minute = 0;
    date = [_gregorian dateFromComponents:components];     
    event.startDate = date;
    event.allDay = YES;
    event.title = @"Sample event 3.";
    [events addObject:event];
    
    event = [EKEvent eventWithEventStore:self.eventStore];
    date = [NSDate dateWithTimeIntervalSinceNow:60*60*24*2];
    components = [_gregorian components:dateTimeFlags fromDate:date];
    components.minute = 0;
    date = [_gregorian dateFromComponents:components];     
    event.startDate = date;
    event.title = @"Sample event 4.";
    [events addObject:event];
    
    return events;
#else
    NSDate *startDate = [self todayStart];
    NSDate *endDate = [self endDateFrom:startDate];
    NSPredicate *pred = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *events = [self.eventStore eventsMatchingPredicate:pred];
    if ([events count] == 0) {
        return nil;
    }
    return [events sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
#endif
}

- (void)redrawCalendar
{
    // Clear out the view;
    for (UIView *subview in self.calendarView.subviews) {
        [subview removeFromSuperview];
    }
    // Get the events.
    if (self.events == nil) {
        TSLabel *noView = [self getLabelWithBg:YES];
        noView.text = @"No Calendar Events";
        [self.calendarView addSubview:noView];        
    }
    NSDate *currentDay = nil;
    static const NSUInteger maxSpaces = 8;
    NSUInteger spacesUsed = 0;
    for (EKEvent *event in self.events) {
        if (spacesUsed >= maxSpaces) {
            break;
        }
        if (currentDay == nil) {
            UIView *dateHeaderView = [self dateHeaderViewFor:event.startDate];
            currentDay = event.startDate;
            [self.calendarView addSubview:dateHeaderView];
            spacesUsed += 1;
            
        } else {
            if (![self sameDay:event.startDate to:currentDay]) {
                currentDay = event.startDate;
                UIView *dateHeaderView = [self dateHeaderViewFor:event.startDate];
                // Reposition.
                [self moveView:dateHeaderView down:spacesUsed];
                [self.calendarView addSubview:dateHeaderView];
                spacesUsed += 1;
                if (spacesUsed >= maxSpaces) {
                    break;
                }
            }
        }
        // Add the event.
        UIView *eventView = [self viewForEvent:event];
        [self moveView:eventView down:spacesUsed];
        [self.calendarView addSubview:eventView];
        spacesUsed += 1;
    }
    
}

- (void)doTask
{
    if (self.eventStore == nil) {
        self.eventStore = [[EKEventStore alloc] init];
    }
    // Get the events.
    self.events = [self getEvents];    
}


@end
