//
//  TSLocation.h
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol TSLocationDelegate
        
- (void)locationNeedsInput;
- (void)locationConfirm:(CLLocation *)location;

@end

@interface TSLocation : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, weak) NSObject<TSLocationDelegate> *delegate;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSTimer *stopTimer;

// Starts the location service on a background thread.
// Once results are ready, the delegate is called.
- (void)getLocation;
// XXX: Handle canceling when going into background.

@end
