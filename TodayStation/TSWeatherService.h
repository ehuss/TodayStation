//
//  TSWeatherService.h
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSWeatherController.h"
#import "TSBackgroundService.h"

extern NSString *TSWeatherReadyNotification;

@interface TSWeatherService : TSBackgroundService

- (UIView *)buildForeView;
- (UIView *)buildTallView;
- (UIView *)buildCurrentView;

@end
