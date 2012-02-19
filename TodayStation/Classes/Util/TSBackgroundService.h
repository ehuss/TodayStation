//
//  TSBackgroundService.h
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kTSStatusUnknown,
    kTSStatusSuccess,
    kTSStatusFailure,
    kTSStatusStarting,
    kTSStatusRunning,
} UpdateStatus;

@interface TSBackgroundService : NSObject {
@protected
    NSTimeInterval updateInterval;
}

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) NSOperation *currentOperation;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, assign) UpdateStatus status;
@property (nonatomic, assign) NSString *notificationName;

// Public.
- (void)start;
- (void)pause;
// This forces the task to start immediately.
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
