//
//  TSRecent.h
//  TodayStation
//
//  Created by Eric Huss on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Data format:
 {"wunderground": [entry,...]}
 
 entry = {"name": "Descriptive name",
          "type": "location" | "airport" | "pws",
          "id": "wunderground query format",
         }

id examples:
 CA/San_Francisco
 94123
 Australia/Sydney
 37.8,-122.4
 KSFO
 pws:KCASANFR70
 
 */

@interface TSRecent : NSObject

@property (nonatomic, strong) NSMutableDictionary *data;

+ (TSRecent *)sharedRecent;
- (void)load;
- (void)save;
- (NSMutableArray *)arrayForService:(NSString *)service;
- (NSMutableArray *)arrayForCurrentService;

@end
