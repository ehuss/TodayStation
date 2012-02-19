//
//  TSWeatherIcons.h
//  TodayStation
//
//  Created by Eric Huss on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kTSIconChanceFlurries,
    kTSIconChanceRain,
    kTSIconChanceSleet,
    kTSIconChanceSnow,
    kTSIconChanceStorms,
    kTSIconClear,
    kTSIconCloudy,
    kTSIconFlurries,
    kTSIconFog,
    kTSIconHazy,
    kTSIconMostlyCloudy,
    kTSIconMostlySunny,
    kTSIconPartlyCloudy,
    kTSIconPartlySunny,
    KTSIconSleet,
    kTSIconSnow,
    kTSIconSunny,
    kTSIconTStorms,
    kTSIconUnknown,
} TSIconType;

@interface TSWeatherIcons : NSObject

@end
