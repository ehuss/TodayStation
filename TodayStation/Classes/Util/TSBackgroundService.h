//
//  TSBackgroundService.h
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
/*
 This is a wrapper around NSOperation that supports repeated invocation
 with timers.  It is intended to be subclassed with subclasses
 implementing doTask.
 
 Subclasses should check the isCancelled property of currentOperation
 periodically.
 */

#import <Foundation/Foundation.h>

typedef enum {
    kTSStatusUnknown,
    kTSStatusStarting,
    kTSStatusRunning,
    kTSStatusDone,
} TSBackgroundStatus;

@interface TSBackgroundService : NSObject

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) NSOperation *currentOperation;
@property (atomic, strong) NSDate *lastUpdate;
@property (atomic, assign) TSBackgroundStatus status;
@property (nonatomic, assign) NSTimeInterval updateInterval;

// Public.
- (void)start;
- (void)pause;
// This forces the task to start immediately (in background).
// If the task is currently running, this does nothing.
// The timer will restart.
- (void)spawnTaskNow;
- (BOOL)operationIsRunning;

// Private.
- (void)spawnUpdate;
- (void)startOperation;

// Subclasses must implement.
// Should set status and lastUpdate when done.
- (void)doTask;

@end
