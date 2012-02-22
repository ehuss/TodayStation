//
//  TSSettings.h
//  TodayStation
//
//  Created by Eric Huss on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TSTempDefault,
    TSTempCelsius,
    TSTempFahrenheit,
} TSTempUnit;

typedef enum {
    TSTimeDefault,
    TSTime24Hour,
    TSTime12Hour,
} TSTimeUnit;

extern TSTempUnit currentTempUnit(void);
extern TSTimeUnit currentTimeUnit(void);

extern void guess24hour(void);
