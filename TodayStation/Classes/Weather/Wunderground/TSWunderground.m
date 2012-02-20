//
//  TSWunderground.m
//  TodayStation
//
//  Created by Eric Huss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSWunderground.h"
#import "SBJson.h"
#import "TSCache.h"
#import "NSDictionary+TSUtil.h"
#import "TSUtil.h"
#import "TSWundergroundForeCont.h"
#import "TSWundergroundHourlyCont.h"

NSString *wundergroundURL = @"http://api.wunderground.com/api/0897152132573769/";

@implementation TSWunderground

@synthesize data=_data;
@synthesize controller=_controller;
@synthesize geoData=_geoData;

- (TSWundergroundController *)controller
{
    if (_controller == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:[NSBundle mainBundle]];
        TSWundergroundController * controller = [storyboard instantiateViewControllerWithIdentifier:@"Wunderbug Controller"];
        // XXX: Current View size is all funky.
        if (controller.view) {
            self.controller = controller;
        }
    }
    return _controller;
}

- (void)fetchData
{
    TSCache *cache = [TSCache sharedCache];
    // XXX: Match should be location.
    NSData *jsonData = [cache getForName:@"wunderground" withMatch:@""];
    if (jsonData == nil) {
        NSURL *url = [NSURL URLWithString:@"http://api.wunderground.com/api/0897152132573769/conditions/forecast/astronomy/hourly/q/37.8,-122.4.json"];
        NSLog(@"Fetching wunderground: %@", url);
        // XXX STREAM
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        //    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSURLResponse *response;
        NSError *error;
        jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (jsonData == nil) {
            // XXX Error.
            return;
        }
        // XXX: Error checking.
        //    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];        
        // XXX: Only encache if it parses correctly.
        [cache encacheData:jsonData name:@"wunderground" mustMatch:@"" forTime:600];
    } else {
        NSLog(@"Fetched wunderground from cache.");
    }
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // XXX Error handling.
    self.data = [parser objectWithData:jsonData]; //] error:&error];
    
    //NSLog(@"%@", [self.data description]);
    
    /*null -> NSNull
     string -> NSString
     array -> NSMutableArray
     object -> NSMutableDictionary
     true -> NSNumber's -numberWithBool:YES
     false -> NSNumber's -numberWithBool:NO
     integer up to 19 digits -> NSNumber's -numberWithLongLong:
     all other numbers -> NSDecimalNumber*/
}

- (void)doTask
{
    [self fetchData];
    [self.delegate performSelectorOnMainThread:@selector(weatherReady) withObject:nil waitUntilDone:NO];
}

- (NSString *)timeAmPmWithHour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *result;
    if (is24h) {
        if (minute == -1) {
            result = [NSString stringWithFormat:@"%i",
                      hour];
        } else {
            result = [NSString stringWithFormat:@"%02i:%02i",
                      hour, minute];
        }
    } else {
        NSString *period;
        if (hour < 12) {
            if (hour == 0) {
                hour = 12;
            }
            period = @"am";
        } else {
            if (hour != 12) {
                hour -= 12;                    
            }
            period = @"pm";
        }
        if (minute == -1) {
            result = [NSString stringWithFormat:@"%i%@",
                      hour, period];            
        } else {
            result = [NSString stringWithFormat:@"%i:%02i%@",
                      hour, minute, period];            
        }
    }
    return result;    
}

- (TSWundergroundForeCont *)getForecastDayCont
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                         bundle:[NSBundle mainBundle]];
    TSWundergroundForeCont * controller = [storyboard instantiateViewControllerWithIdentifier:@"Wunderground Fore Cont"];
    // XXX: Current View size is all funky.
    if (controller.view) {
        return controller;
    } else {
        // XXX: fatal error.
        return nil;
    }
    
}

- (UIView *)buildDayViewForDay:(int)dayNum
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL celsius = [settings boolForKey:@"celsius"];

    TSWundergroundForeCont *cont = [self getForecastDayCont];
    NSArray *days = [self.data tsObjectForKeyPath:@"forecast.simpleforecast.forecastday" numberToString:NO];
    if (days == nil) {
        // XXX Fatal error.
        NSLog(@"Couldn't find forecastday");
        return nil;
    }
    NSDictionary *dayD = [days objectAtIndex:dayNum];
    NSNumber *epoch = [dayD tsObjectForKeyPath:@"date.epoch" numberToString:NO];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[epoch intValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"EEEE"];
    cont.dayOfWeekView.text = [formatter stringFromDate:date];
    [formatter setDateFormat:@"MMM d"];
    cont.dateView.text = [formatter stringFromDate:date];
    NSDictionary *high = [dayD objectForKey:@"high"];
    NSDictionary *low = [dayD objectForKey:@"low"];
    if (celsius) {
        cont.hiLowView.text = [NSString stringWithFormat:@"%@\xc2\xb0/%@\xc2\xb0",
                               [high objectForKey:@"celsius"],
                               [low objectForKey:@"celsius"]];
    } else {
        cont.hiLowView.text = [NSString stringWithFormat:@"%@\xc2\xb0/%@\xc2\xb0",
                               [high objectForKey:@"fahrenheit"],
                               [low objectForKey:@"fahrenheit"]];
    }
    cont.rainView.text = [NSString stringWithFormat:@"%@%%",
                          [dayD objectForKey:@"pop"]];
    /*
     @property (weak, nonatomic) IBOutlet UIImageView *iconView;
*/
    return cont.dayView;
}

- (UIView *)buildHourViewForHour:(int)hour
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL celsius = [settings boolForKey:@"celsius"];
    
    // Get a controller.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                         bundle:[NSBundle mainBundle]];
    TSWundergroundHourlyCont * cont = [storyboard instantiateViewControllerWithIdentifier:@"Wunderground Hourly Cont"];
    // XXX: Current View size is all funky.
    // Force view to init.
    if (cont.view == nil) {
        // XXX Fatal error;
        return nil;
    }

    NSArray *hours = [self.data objectForKey:@"hourly_forecast"];
    if (hours == nil) {
        // XXX Fatal error.
        NSLog(@"Couldn't find hourly_forecast");
        return nil;
    }
    NSDictionary *hourD = [hours objectAtIndex:hour];
    NSNumber *hourN = [hourD tsObjectForKeyPath:@"FCTTIME.hour" numberToString:NO];
    cont.timeView.text = [self timeAmPmWithHour:[hourN intValue] minute:-1];
    NSDictionary *tempD = [hourD objectForKey:@"temp"];
    if (celsius) {
        cont.tempView.text = [NSString stringWithFormat:@"%@\xc2\xb0",
                              [tempD objectForKey:@"metric"]];
    } else {
        cont.tempView.text = [NSString stringWithFormat:@"%@\xc2\xb0",
                              [tempD objectForKey:@"english"]];
    }
    cont.popView.text = [NSString stringWithFormat:@"%@%%",
                         [hourD objectForKey:@"pop"]];
    return cont.hourView;    
}

- (UIView *)buildForeView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 512, 270)];
    
    // XXX assuming 4 days with first being today.
    for (int i=0; i<3; i++) {
        UIView *dayView = [self buildDayViewForDay:i+1];
        // Move into position.
        CGRect f = dayView.frame;
        dayView.frame = CGRectMake(f.origin.x, f.size.height*i,
                                   f.size.width, f.size.height);
        [view addSubview:dayView];
    }
    
    return view;
}

- (UIView *)buildTallView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 280, 511, 488)];
    
    for (int i=0; i<18; i++) {
        UIView *hourView = [self buildHourViewForHour:i];
        // Move into position.
        CGRect f = hourView.frame;
        hourView.frame = CGRectMake(f.origin.x, f.size.height*i,
                                    f.size.width, f.size.height);
        [view addSubview:hourView];
    }
    
    return view;
}
- (UIView *)buildCurrentView
{
    TSWundergroundController *c = self.controller;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL celsius = [settings boolForKey:@"celsius"];
    
    // ======================================================================
    // Current Conditions
    // ======================================================================
    NSDictionary *currentObs = [self.data objectForKey:@"current_observation"];
    if (currentObs == nil) {
        // XXX Terminal error.
        NSLog(@"Failed to get current_observation.");
        NSLog(@"%@", [self.data description]);
    }

    // Temperature.
    NSString *curTemp;
    if (celsius) {
        curTemp = [NSString stringWithFormat:@"%@\xc2\xb0", [currentObs objectForKey:@"temp_c"]];
    } else {
        curTemp = [NSString stringWithFormat:@"%@\xc2\xb0", [currentObs objectForKey:@"temp_f"]];        
    }
    c.currentTempView.text = curTemp;

    // Wind.
    id windDeg = [currentObs objectForKey:@"wind_degrees"];
    if ([windDeg isKindOfClass:[NSNumber class]]) {
        int deg = [windDeg intValue];
        NSString *windDir;
        if (deg >= 337.5 || deg <= 22.5) {
            windDir = @"N";
        } else if (deg > 22.5 && deg <= 67.5) {
            windDir = @"NE";
        } else if (deg > 67.5 && deg <= 112.5) {
            windDir = @"E";
        } else if (deg > 112.5 && deg <= 157.5) {
            windDir = @"SE";
        } else if (deg > 157.5 && deg <= 202.5) {
            windDir = @"S";
        } else if (deg > 202.5 && deg <= 247.5) {
            windDir = @"SW";
        } else if (deg > 247.5 && deg <= 292.5) {
            windDir = @"W";
        } else if (deg > 292.5 && deg <= 337.5) {
            windDir = @"NW";
        } else {
            NSLog(@"wind_degrees didn't parse correctly: %i", deg);
            windDir = @"";
        }
        
        // XXX mph/kph
        NSString *windMPH = [[currentObs objectForKey:@"wind_mph"] description];
        
        NSString *windStr = [NSString stringWithFormat:@"%@ %@mph",
                             windDir, windMPH];
        c.currentWindView.text = windStr;
    } else {
        NSLog(@"wind_degrees unexpected type: %@ %@",
              [windDeg description], NSStringFromClass([windDeg class]));
        c.currentWindView.text = @"";
    }
    
    // ======================================================================
    // Forecast
    // ======================================================================
    // Assuming that forecastday array is sorted and first item is today.
    NSDictionary *forecast = [self.data 
                              tsObjectForKeyPath:@"forecast.simpleforecast.forecastday[0]" numberToString:NO];
    if (forecast != nil) {
        NSDictionary *highD = [forecast objectForKey:@"high"];
        NSDictionary *lowD = [forecast objectForKey:@"low"];
        NSString *high, *low;
        if (celsius) {
            high = [NSString stringWithFormat:@"%@\xc2\xb0", [highD objectForKey:@"celsius"]];
            low = [NSString stringWithFormat:@"%@\xc2\xb0", [lowD objectForKey:@"celsius"]];
        } else {
            high = [NSString stringWithFormat:@"%@\xc2\xb0", [highD objectForKey:@"fahrenheit"]];
            low = [NSString stringWithFormat:@"%@\xc2\xb0", [lowD objectForKey:@"fahrenheit"]];
        }
        c.hiTempView.text = high;
        c.lowTempView.text = low;
    } else {
        // XXX: Fatal error.
        NSLog(@"forecast not found.");
        c.hiTempView.text = @"";
        c.lowTempView.text = @"";
    }
    
    
    // ======================================================================
    // Astronomy
    // ======================================================================
    NSDictionary *astronomy = [self.data objectForKey:@"moon_phase"];
    if (astronomy != nil) {
        NSDictionary *sunriseD = [astronomy objectForKey:@"sunrise"];
        NSDictionary *sunsetD = [astronomy objectForKey:@"sunset"];
        NSInteger sunriseHour = [[sunriseD objectForKey:@"hour"] intValue];
        NSInteger sunriseMin = [[sunriseD objectForKey:@"minute"] intValue];
        NSInteger sunsetHour = [[sunsetD objectForKey:@"hour"] intValue];
        NSInteger sunsetMin = [[sunsetD objectForKey:@"minute"] intValue];
        
        // Times are in "local" timezone 24-hour format.
        // Safely converting from
        // NSDate (NSCalendar)-> NSComponents (NSCalendar)->NSDate (NSDateFormatter)->NSString
        // Is probably somewhat unrealiable (timezones, DST changes, etc.)
        // Just manually format based on our guess for 12/24 hour clock.
        c.sunriseView.text = [self timeAmPmWithHour:sunriseHour minute:sunriseMin];
        c.sunsetView.text = [self timeAmPmWithHour:sunsetHour minute:sunsetMin];
    } else {
        // XXX: fatal error
        c.sunriseView.text = @"";
        c.sunsetView.text = @"";
    }
    
    // XXX
    //c.currentImageView.x = ;
    //c.moonPhaseView.x = ;

    return c.currentView;
}

- (void)bgGeoLookup:(CLLocation *)location
{
    NSString *urlStr = [NSString stringWithFormat:@"%@geolookup/q/%f,%f.json",
                        wundergroundURL,
                        location.coordinate.latitude,
                        location.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"Fetching wunderground: %@", url);
    // XXX STREAM
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    //    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSURLResponse *response;
    NSError *error;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (jsonData == nil) {
        // XXX Error.
        return;
    }
    // XXX: Error checking.
    //    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];        

    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // XXX Error handling.
    self.geoData = [parser objectWithData:jsonData]; //] error:&error];
}

@end
