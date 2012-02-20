//
//  TSLocationSearchController.h
//  TodayStation
//
//  Created by Eric Huss on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 TODO: Create init that passes in source?
 */

#import <UIKit/UIKit.h>
// XXX Make this generic.
#import "TSWundergroundLocationSource.h"
#import "TSWeatherService.h"

@interface TSLocationSearchController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) TSWundergroundLocationSource *source;

- (void)setInitialLocation:(CLLocation *)location;

@end
