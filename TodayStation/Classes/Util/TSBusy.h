//
//  TSBusy.h
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSBusy : NSObject

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *labelView;

- (id)initWithFrame:(CGRect)frame;

@end
