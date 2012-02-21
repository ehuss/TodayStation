//
//  TSUtil.m
//  TodayStation
//
//  Created by Eric Huss on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TSUtil.h"

BOOL is24h = NO;

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

TSLabel * createLabel(CGRect frame, BOOL bg)
{
    TSLabel *view = [[TSLabel alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
    view.text = @"test";
    view.layer.cornerRadius = 8;
    
    if (bg) {
        view.gradient = [NSArray arrayWithObjects:(id)[UIColor darkGrayColor].CGColor,
                         (id)[UIColor blackColor].CGColor,
                         nil];
        view.textRect = CGRectOffset(view.bounds, 5, 0);
    }    
    
    return view;
}
