//
//  TSBackgroundService.m
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSBackgroundService.h"

@implementation TSBackgroundService
@synthesize updateTimer = _updateTimer;
@synthesize currentOperation = _currentOperation;
@synthesize lastUpdate = _lastUpdate;
@synthesize status = _status;
@synthesize updateInterval = _updateInterval;

- (id)init
{
    if (self = [super init]) {
        _updateInterval = 3600;
        _status = kTSStatusUnknown;
        return self;
    }
    return nil;
}

- (void)createTimer
{
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:_updateInterval target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];                
}

- (void)start
{
    if (self.updateTimer == nil) {
        if (self.lastUpdate == nil ||
            [self.lastUpdate timeIntervalSinceNow] > _updateInterval) {
            [self spawnUpdate];
        }
        [self createTimer];
    }
}

- (void)pause
{
    if (self.updateTimer != nil) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
    if (self.currentOperation != nil) {
        [self.currentOperation cancel];
    }
}

- (void)spawnTaskNow
{
    if ([self operationIsRunning]) {
        NSLog(@"Can't spawn, task is already running.");
        return;
    }
    // Invalidate timer so that we can reset it.
    [self pause];
    [self spawnUpdate];
    [self createTimer];    
}

- (BOOL)operationIsRunning
{
    return !(self.currentOperation == nil || [self.currentOperation isFinished]);
}

- (void)spawnUpdate
{
    if (![self operationIsRunning]) {
        self.status = kTSStatusStarting;
        self.currentOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(startOperation) object:nil];
        [[NSOperationQueue currentQueue] addOperation:self.currentOperation];
    }
}

- (void)startOperation
{
    self.status = kTSStatusRunning;
    [self doTask];
    self.status = kTSStatusDone;
    self.lastUpdate = [NSDate date];
}

- (void)updateTimerFired:(NSTimer *)timer
{
    [self spawnUpdate];
}

- (void)doTask
{
    // Must override.
}

@end
