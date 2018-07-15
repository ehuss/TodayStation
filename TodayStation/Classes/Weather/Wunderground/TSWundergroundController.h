//
//  TSWundergroundController.h
//  Today Station
//
//  Created by Eric Huss on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSWeatherController.h"

@interface TSWundergroundController : TSWeatherController

// Strong since it is reused (and can be temporarily removed from superview).
@property (strong, nonatomic) IBOutlet UIView *currentView;
@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *moonPhaseView;
@property (weak, nonatomic) IBOutlet UILabel *hiTempView;
@property (weak, nonatomic) IBOutlet UILabel *lowTempView;
@property (weak, nonatomic) IBOutlet UILabel *currentTempView;
@property (weak, nonatomic) IBOutlet UILabel *currentWindView;
@property (weak, nonatomic) IBOutlet UILabel *sunriseView;
@property (weak, nonatomic) IBOutlet UILabel *sunsetView;
@end
