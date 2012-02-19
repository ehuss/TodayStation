//
//  TSBackgroundService.m
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSBackgroundService.h"
#import "NSNotificationCenter+MainThread.h"

@implementation TSBackgroundService
@synthesize updateTimer = _updateTimer;
@synthesize currentOperation = _currentOperation;
@synthesize lastUpdate = _lastUpdate;
@synthesize status = _status;
@synthesize notificationName = _notificationName;

- (id)init
{
    if (self = [super init]) {
        updateInterval = 3600;
        _status = kTSStatusUnknown;
        return self;
    }
    return nil;
}

- (void)createTimer
{
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];                
}

- (void)start
{
    if (self.updateTimer == nil) {
        if (self.lastUpdate == nil ||
            [self.lastUpdate timeIntervalSinceNow] > updateInterval) {
            [self spawnUpdate];
        }
        [self createTimer];
    }
}

- (void)pause
{
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    // XXX Halt operation.
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
    NSNotification *notification = [NSNotification 
                                    notificationWithName:self.notificationName 
                                    object:self];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    // Note: No support for coalescing using this technique.
    // Not sure how to get the NSNotificationQueue for the main thread.
    // (defaultQueue is per thread).
    [center postNotificationOnMainThread:notification];
}

- (void)updateTimerFired:(NSTimer *)timer
{
    [self spawnUpdate];
}

- (void)doTask
{
    // Must override.
    self.status = kTSStatusFailure;
}

- (void)mainThreadNotification:(NSNotification *)notification
{
    // Does nothing.
}


@end
