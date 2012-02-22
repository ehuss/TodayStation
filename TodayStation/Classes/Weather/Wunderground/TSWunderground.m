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
#import "TSSettings.h"
#import "TSColors.h"

NSString *wundergroundURL = @"http://api.wunderground.com/api/0897152132573769/";

typedef enum {
    TSIconLarge,
    TSIconMedium,
    TSIconSmall,
} TSIconSize;

@implementation TSWunderground

@synthesize data=_data;
@synthesize controller=_controller;
@synthesize geoData=_geoData;
@synthesize autocompleteDelegate=_autocompleteDelegate;
@synthesize autocompleteOp=_autocompleteOp;
@synthesize autocompleteTimer=_autocompleteTimer;
@synthesize lastAutocomplete=_lastAutocomplete;
@synthesize isDaylight=_isDaylight;

- (TSWundergroundController *)controller
{
    if (_controller == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:[NSBundle mainBundle]];
        TSWundergroundController * controller = [storyboard instantiateViewControllerWithIdentifier:@"Wunderbug Controller"];
        if (controller.view) {
            self.controller = controller;
            TScolorize(controller.currentView);
        }
    }
    return _controller;
}

- (void)computeIsDaylight
{
    NSDictionary *astronomy = [self.data objectForKey:@"moon_phase"];
    if (astronomy != nil) {
        NSDictionary *sunriseD = [astronomy objectForKey:@"sunrise"];
        NSDictionary *sunsetD = [astronomy objectForKey:@"sunset"];
        NSInteger sunriseHour = [[sunriseD objectForKey:@"hour"] intValue];
        NSInteger sunriseMin = [[sunriseD objectForKey:@"minute"] intValue];
        NSInteger sunsetHour = [[sunsetD objectForKey:@"hour"] intValue];
        NSInteger sunsetMin = [[sunsetD objectForKey:@"minute"] intValue];

        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit
                                                    fromDate:[NSDate date]];
        NSInteger currentHour = components.hour;
        NSInteger currentMin = components.minute;
        if ( ((currentHour==sunriseHour && currentMin>=sunriseMin) ||
              (currentHour>sunriseHour)) &&
            ((currentHour==sunsetHour && currentMin<=sunsetMin) ||
             (currentHour<sunsetHour))) {
            self.isDaylight = YES;
        } else {
            self.isDaylight = NO;
        }
    }
}

- (void)fetchData:(NSString *)query
{
    TSCache *cache = [TSCache sharedCache];
    // XXX: Match should be location.
    NSData *jsonData = [cache getForName:@"wunderground" withMatch:query];
    if (jsonData == nil) {
        NSString *urlStr = [NSString stringWithFormat:@"%@conditions/forecast/astronomy/hourly/q/%@.json",
                            wundergroundURL,
                            query];
        NSURL *url = [NSURL URLWithString:urlStr];
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
        [cache encacheData:jsonData name:@"wunderground" mustMatch:query forTime:600];
    } else {
        NSLog(@"Fetched wunderground from cache.");
    }
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // XXX Error handling.
    self.data = [parser objectWithData:jsonData]; //] error:&error];
    [self computeIsDaylight];
    
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
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *query = [settings stringForKey:@"wundergroundQuery"];
    if (query == nil) {
        return;
    }
    [self fetchData:query];
    [self.delegate performSelectorOnMainThread:@selector(weatherReady) withObject:nil waitUntilDone:NO];
}

- (NSString *)timeAmPmWithHour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *result;
    if (currentTimeUnit()==TSTime24Hour) {
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

- (UIImage *)loadIcon:(NSString *)what withSize:(TSIconSize)size dayOnly:(BOOL)dayOnly
{
    NSString *sizeStr;
    if (size == TSIconLarge) {
        sizeStr = @"large";
    } else if (size == TSIconMedium) {
        sizeStr = @"medium";
    } else if (size == TSIconSmall) {
        sizeStr = @"small";
    }
    NSString *ndStr;
    if (dayOnly || self.isDaylight) {
        ndStr = @"day";
    } else {
        ndStr = @"night";
    }
    NSString *name = [NSString stringWithFormat:@"Images/Weather/%@-%@-%@",
                      what,
                      ndStr,
                      sizeStr];
    UIImage *result = [UIImage imageNamed:name];
    if (result == nil) {
        name = [NSString stringWithFormat:@"Images/Weather/%@-%@",
                what,
                sizeStr];
        result = [UIImage imageNamed:name];
    }
    if (result == nil) {
        NSLog(@"Couldn't find icon for %@ %@", what, sizeStr);
        name = [NSString stringWithFormat:@"Images/Weather/unknown-%@",
                sizeStr];
        result = [UIImage imageNamed:name];        
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
        TScolorize(controller.view);
        return controller;
    } else {
        // XXX: fatal error.
        return nil;
    }
    
}

- (UIView *)buildDayViewForDay:(int)dayNum
{
    TSTempUnit tempUnit = currentTempUnit();

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
    // Abbreviated day of week.
    [formatter setDateFormat:@"EEE"];
    cont.dayOfWeekView.text = [formatter stringFromDate:date];
    // Abbreviated month and day.
    [formatter setDateFormat:@"MMM d"];
    cont.dateView.text = [formatter stringFromDate:date];
    NSDictionary *high = [dayD objectForKey:@"high"];
    NSDictionary *low = [dayD objectForKey:@"low"];
    if (tempUnit == TSTempCelsius) {
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
    // Icon
    NSString *iconStr = [dayD objectForKey:@"icon"];
    UIImage *icon = [self loadIcon:iconStr withSize:TSIconMedium dayOnly:YES];
    if (icon) {
        cont.iconView.image = icon;
    } else {
        cont.iconView.image = nil;
    }
    return cont.dayView;
}

- (UILabel *)createHourLabel:(CGRect)frame
{
    TSLabel *label = createLabel(frame, NO);
    label.textAlignment = UITextAlignmentRight;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:27];
    return label;
}

- (UIView *)buildHourViewForHour:(int)hour
{    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 231, 27)];
    TSTempUnit tempUnit = currentTempUnit();

    NSArray *hours = [self.data objectForKey:@"hourly_forecast"];
    if (hours == nil) {
        // XXX Fatal error.
        NSLog(@"Couldn't find hourly_forecast");
        return nil;
    }
    NSDictionary *hourD = [hours objectAtIndex:hour];
    NSNumber *hourN = [hourD tsObjectForKeyPath:@"FCTTIME.hour" numberToString:NO];
    UILabel *timeLabel = [self createHourLabel:CGRectMake(0, 0, 74, 27)];
    timeLabel.text = [self timeAmPmWithHour:[hourN intValue] minute:-1];
    NSDictionary *tempD = [hourD objectForKey:@"temp"];
    UILabel *tempLabel = [self createHourLabel:CGRectMake(82, 0, 57, 27)];
    if (tempUnit == TSTempCelsius) {
        tempLabel.text = [NSString stringWithFormat:@"%@\xc2\xb0",
                              [tempD objectForKey:@"metric"]];
    } else {
        tempLabel.text = [NSString stringWithFormat:@"%@\xc2\xb0",
                              [tempD objectForKey:@"english"]];
    }
    UILabel *popLabel = [self createHourLabel:CGRectMake(147, 0, 84, 27)];
    popLabel.text = [NSString stringWithFormat:@"%@%%",
                         [hourD objectForKey:@"pop"]];
    [view addSubview:timeLabel];
    [view addSubview:tempLabel];
    [view addSubview:popLabel];
    return view;
}

- (UIView *)buildForeView
{
    // XXX: Protect against no data.
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
    // XXX: Protect against no data.
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 280, 511, 488)];
    view.userInteractionEnabled = NO;
    
    /*for (int i=0; i<16; i++) {
        UIView *hourView = [self buildHourViewForHour:i];
        // Move into position.
        CGRect f = hourView.frame;
        hourView.frame = CGRectMake(f.origin.x, f.size.height*i,
                                    f.size.width, f.size.height);
        [view addSubview:hourView];
    }*/
    for (int i=0; i<16; i++) {
        UIView *hourView = [self buildHourViewForHour:i];
        // Move into position.
        CGRect f = hourView.frame;
        hourView.frame = CGRectMake(250, f.size.height*i,
                                    f.size.width, f.size.height);
        [view addSubview:hourView];
    }
    
    UILabel *lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    lastUpdateLabel.text = [self.data tsObjectForKeyPath:@"current_observation.observation_time" numberToString:NO];
    lastUpdateLabel.backgroundColor = [UIColor clearColor];
    lastUpdateLabel.textColor = [TSColors theCurrentColor].deemphasizedColor;
    lastUpdateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    [lastUpdateLabel sizeToFit];
    CGRect f = lastUpdateLabel.frame;
    lastUpdateLabel.frame = CGRectMake(501-f.size.width, 488-f.size.height,
                                       f.size.width, f.size.height);
    [view addSubview:lastUpdateLabel];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    locationLabel.text = [self.data tsObjectForKeyPath:@"current_observation.observation_location.full" numberToString:NO];
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.textColor = [TSColors theCurrentColor].deemphasizedColor;
    locationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    [locationLabel sizeToFit];
    CGRect updateF = lastUpdateLabel.frame;
    CGRect locatF = locationLabel.frame;
    locationLabel.frame = CGRectMake(501-locatF.size.width, updateF.origin.y-locatF.size.height,
                                       locatF.size.width, locatF.size.height);
    [view addSubview:locationLabel];

    return view;
}

- (UIView *)buildCurrentView
{
    // XXX: Protect against no data.
    TSWundergroundController *c = self.controller;
    TScolorize(c.currentView);
    TSTempUnit tempUnit = currentTempUnit();
    
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
    if (tempUnit == TSTempCelsius) {
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
    
    // Icon
    NSString *iconStr = [currentObs objectForKey:@"icon"];
    UIImage *icon = [self loadIcon:iconStr withSize:TSIconLarge dayOnly:NO];
    if (icon) {
        c.currentImageView.image = icon;
    } else {
        c.currentImageView.image = nil;
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
        if (tempUnit == TSTempCelsius) {
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

- (void)bgGeoLookup:(NSString *)query
{
    NSString *urlStr = [NSString stringWithFormat:@"%@geolookup/q/%@.json",
                        wundergroundURL,
                        [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
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

- (void)startAutocompletePollerOnDelegate:(NSObject <TSWundergroundAutoDelegate>*)delegate
{
    NSLog(@"Starting autocomplete timer.");
    if (self.autocompleteTimer == nil) {
        self.autocompleteDelegate = delegate;
        self.autocompleteTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autocompleteFired:) userInfo:nil repeats:YES];
    }
}

- (void)signalAutocompleteWithResults:(NSArray *)results
{
    NSLog(@"Signaling with %i results", [results count]);
    [self.autocompleteDelegate performSelectorOnMainThread:@selector(setResultsForAutocomplete:) withObject:results waitUntilDone:NO];
}

- (void)autocompleteFired:(NSTimer *) timer
{
    NSLog(@"timer fired");
    NSString *currentString = [self.autocompleteDelegate getCurrentSearchString];
    if (self.lastAutocomplete==nil || [self.lastAutocomplete compare:currentString]!=NSOrderedSame) {
        NSLog(@"Search string changed.");
        // Search string has changed.  See if there is an op in progress.
        if (self.autocompleteOp==nil || [self.autocompleteOp isFinished]) {
            NSLog(@"autocomplete not running, starting");
            self.lastAutocomplete = currentString;
            self.autocompleteOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchAutocomplete) object:nil];
            [[NSOperationQueue currentQueue] addOperation:self.autocompleteOp];        
        }
    }
}

- (void)fetchAutocomplete
{
    // XXX: Will wunderground ever return a value "type"!="city"?
    if ([self.autocompleteOp isCancelled]) {
        return;
    }
    if ([self.lastAutocomplete length]==0) {
        NSLog(@"empty search string");
        [self signalAutocompleteWithResults:[NSArray array]];
        return;        
    }
    NSString *escaped = [self.lastAutocomplete stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlStr = [NSString stringWithFormat:@"http://autocomplete.wunderground.com/aq?query=%@&format=JSON", escaped];
    NSLog(@"Wunderground autocomplete: %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLResponse *response;
    NSError *error;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (jsonData == nil) {
        // XXX: Error handling.
        [self signalAutocompleteWithResults:[NSArray array]];
        return;
    }
    if ([self.autocompleteOp isCancelled]) {
        return;
    }
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *resultsD = [parser objectWithData:jsonData];
    // XXX: Error handling.
    NSArray *results = [resultsD objectForKey:@"RESULTS"];
    [self signalAutocompleteWithResults:results];
}

- (void)stopAutocompletePoller
{
    NSLog(@"Stopping autocomplete.");
    [self.autocompleteTimer invalidate];
    self.autocompleteTimer = nil;
    [self.autocompleteOp cancel];
}

@end
