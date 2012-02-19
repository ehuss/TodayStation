//
//  TSWundergroundForeCont.h
//  TodayStation
//
//  Created by Eric Huss on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSWundergroundForeCont : UIViewController
@property (weak, nonatomic) IBOutlet UIView *dayView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *dayOfWeekView;
@property (weak, nonatomic) IBOutlet UILabel *dateView;
@property (weak, nonatomic) IBOutlet UILabel *hiLowView;
@property (weak, nonatomic) IBOutlet UILabel *rainView;

@end
