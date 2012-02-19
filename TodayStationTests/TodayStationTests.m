//
//  TodayStationTests.m
//  TodayStationTests
//
//  Created by Eric Huss on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TodayStationTests.h"
#import "TSCache.h"

@implementation TodayStationTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    [TSCache sharedCache];
    //STFail(@"Unit tests are not implemented yet in TodayStationTests");
}

@end
