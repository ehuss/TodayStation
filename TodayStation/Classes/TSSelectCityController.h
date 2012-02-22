//
//  TSSelectCityController.h
//  TodayStation
//
//  Created by Eric Huss on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRecent.h"
// XXX Make service generic.
#import "TSWunderground.h"

@interface TSSelectCityController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, TSWundergroundAutoDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchCont;
@property (nonatomic, strong) TSRecent *recent;
@property (nonatomic, strong) NSArray *searchResults;

- (void)pushStationControllerWithQuery:(NSString *)query;
@end
