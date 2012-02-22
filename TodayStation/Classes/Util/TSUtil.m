//
//  TSUtil.m
//  TodayStation
//
//  Created by Eric Huss on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TSUtil.h"
#import "TSColors.h"

TSLabel * createLabel(CGRect frame, BOOL bg)
{
    TSLabel *view = [[TSLabel alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.textColor = [TSColors theCurrentColor].textColor;
    view.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
    view.text = @"test";
    view.layer.cornerRadius = 8;
    
    if (bg) {
        view.gradient = [NSArray arrayWithObjects:(id)[TSColors theCurrentColor].deemphasizedColor.CGColor,
                         (id)[TSColors theCurrentColor].backgroundColor.CGColor,
                         nil];
        view.textRect = CGRectOffset(view.bounds, 5, 0);
    }    
    
    return view;
}
