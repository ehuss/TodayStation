//
//  TSSettings.m
//  TodayStation
//
//  Created by Eric Huss on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSSettings.h"

TSTempUnit currentTempUnit(void)
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    TSTempUnit currentUnit;
    currentUnit = (TSTempUnit) [settings integerForKey:@"tempUnit"];
    if (currentUnit == TSTempDefault) {
        BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
        if (isMetric) {
            return TSTempCelsius;
        } else {
            return TSTempFahrenheit;
        }
    }
    return currentUnit;    
}

static BOOL is24h = NO;

void guess24hour(void)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSLog(@"%@", dateString);
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);    
}

TSTimeUnit currentTimeUnit(void)
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    TSTimeUnit currentUnit;
    currentUnit = (TSTimeUnit) [settings integerForKey:@"timeUnit"];
    if (currentUnit == TSTimeDefault) {
        if (is24h) {
            return TSTime24Hour;
        } else {
            return TSTime12Hour;
        }
    }
    return currentUnit;    
}