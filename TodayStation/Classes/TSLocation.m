//
//  TSLocation.m
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSLocation.h"
#import "NSNotificationCenter+MainThread.h"

@implementation TSLocation {
    BOOL _stopping;
}

@synthesize manager=_manager;
@synthesize delegate=_delegate;
@synthesize lastLocation=_lastLocation;
@synthesize stopTimer=_stopTimer;

- (void)getLocation
{
    // Start on a background thread.
    NSOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(startOperation) object:nil];
    [[NSOperationQueue currentQueue] addOperation:operation];    
}

- (void)signalDelegateWithSel:(SEL)sel withData:(id)data
{
    [self.delegate performSelectorOnMainThread:sel
                                    withObject:data waitUntilDone:NO];
    
}   

- (void)startOperation
{
    _stopping = NO;
    if (self.manager == nil) {
        self.manager = [[CLLocationManager alloc] init];
    }
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location services unavailable.");
        [self signalDelegateWithSel:@selector(locationNeedsInput) withData:nil];
        return;
    }
    self.stopTimer = [NSTimer timerWithTimeInterval:60
                                             target:self
                                           selector:@selector(stopTimerFired:)
                                           userInfo:nil repeats:NO];
    self.manager.distanceFilter = kCLLocationAccuracyKilometer;
    self.manager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
}

- (void)shutdown
{
    _stopping = YES;
    [self.stopTimer invalidate];
    [self.manager stopUpdatingLocation];
}

- (void)stopTimerFired:(NSTimer *)timer
{
    [self shutdown];
    if (self.lastLocation == nil) {
        [self signalDelegateWithSel:@selector(locationNeedsInput) withData:nil];
    } else {
        [self signalDelegateWithSel:@selector(locationConfirm:)
                           withData:self.lastLocation];
    }
}

// ===========================================================================
// Location Delegate
// ===========================================================================
- (void)locationManager:(CLLocationManager *)manager
        didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (_stopping) return;
    NSLog(@"status set to %i", status);
    if (status == kCLAuthorizationStatusNotDetermined) {
        // ignore.  I don't think this should ever get delivered.
    } else if (status == kCLAuthorizationStatusRestricted) {
        // Parental Controls, give up.
        [self shutdown];
        [self signalDelegateWithSel:@selector(locationNeedsInput) withData:nil];
    } else if (status == kCLAuthorizationStatusDenied) {
        // Harsh, give up.
        [self shutdown];
        [self signalDelegateWithSel:@selector(locationNeedsInput) withData:nil];
    } else if (status == kCLAuthorizationStatusAuthorized) {
        // Woot!
        // Nothing to do but wait for updates.        
        // Don't need to wait as long.
        [self.stopTimer invalidate];
        self.stopTimer = [NSTimer timerWithTimeInterval:20 target:self selector:@selector(stopTimerFired:) userInfo:nil repeats:NO];
    } else {
        // Unknown value, ignore.
    }
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (_stopping) {
        return;
    }
    // Filter out old cached values.
    if ([newLocation.timestamp timeIntervalSinceNow] < -5*60) {
        // More than 5 minutes old, ignore.
        self.lastLocation = newLocation;
        NSLog(@"Location: Ignoring old location: %g",
              [newLocation.timestamp timeIntervalSinceNow]);
        return;
    }
    // Just check that the accuracy is sane.  If not, ignore.
    // lat/long is center. this is radius in meters.  negative is invalid
    if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 1000) {
        NSLog(@"Location: Ignoring extreme horizontalAccuracy %g",
              newLocation.horizontalAccuracy);
        return;
    }
    // Use this location.
    [self shutdown];
    [self signalDelegateWithSel:@selector(locationConfirm:) withData:newLocation];
    
    NSLog(@"update location %@.", newLocation);
    // coordinate (2d)
    // altitude double
    // horizontalAccuracy
    // verticalAccuracy
    // timestamp
    // description
//    CLLocationCoordinate2D latitude,longitude (double)
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (_stopping) {
        return;
    }
    NSLog(@"monitoring fail %@", error);
    [self shutdown];
    [self signalDelegateWithSel:@selector(locationNeedsInput) withData:nil];
}

@end
