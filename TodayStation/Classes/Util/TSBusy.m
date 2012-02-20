//
//  TSBusy.m
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSBusy.h"

@implementation TSBusy

@synthesize container=_container;
@synthesize activityView=_activityView;
@synthesize labelView=_labelView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.container = [[UIView alloc] initWithFrame:frame];
        self.container.backgroundColor = [UIColor clearColor];
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.backgroundColor = [UIColor clearColor];
        CGRect avf = self.activityView.frame;
        CGRect labelRect = CGRectMake(avf.size.width, 0,
                                      frame.size.width-avf.size.width,
                                      avf.size.height);
        self.labelView = [[UILabel alloc] initWithFrame:labelRect];
        self.labelView.backgroundColor = [UIColor clearColor];
        [self.container addSubview:self.activityView];
        [self.container addSubview:self.labelView];
    }
    return self;
}

@end
