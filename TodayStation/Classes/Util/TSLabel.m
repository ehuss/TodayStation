//
//  TSLabel.m
//  TodayStation
//
//  Created by Eric Huss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSLabel.h"
#import "QuartzCore/QuartzCore.h"

@implementation TSLabel

@synthesize gradient=_gradient;
@synthesize textRect=_textRect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textRect = CGRectZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    if (self.gradient != nil) {
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        
        // Figure out color space from first element.
        CGColorRef color = (__bridge CGColorRef)[self.gradient objectAtIndex:0];
        CGColorSpaceRef colorspace = CGColorGetColorSpace(color);

        CGGradientRef theGradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)self.gradient, NULL);
        
        CGRect currentBounds = self.bounds;
        CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
        CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
        CGContextDrawLinearGradient(currentContext, theGradient, topCenter, bottomCenter, 0);
        
        CGGradientRelease(theGradient);
    }
    if (CGRectEqualToRect(self.textRect, CGRectZero)) {
        [super drawTextInRect:rect];
    } else {
        [super drawTextInRect:self.textRect];        
    }
}

@end
