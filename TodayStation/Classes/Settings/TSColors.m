//
//  TSColors.m
//  TodayStation
//
//  Created by Eric Huss on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSColors.h"

void TScolorize(UIView *view)
{
    TSColor *currentColor = [TSColors theCurrentColor];
    if ([view isKindOfClass:[UILabel class]]) {
        ((UILabel *)view).textColor = currentColor.textColor;
    }
    view.backgroundColor = currentColor.backgroundColor;
    for (UIView *subview in view.subviews) {
        TScolorize(subview);
    }
}

@implementation TSColor

@synthesize textColor=_textColor;
@synthesize backgroundColor=_backgroundColor;
@synthesize deemphasizedColor=_deemphasizedColor;
@synthesize name=_name;

+ (id)colorWithName:(NSString *)name
               text:(TSColorStruct)textC
         background:(TSColorStruct)bgC
       deemphasized:(TSColorStruct)deC
{
    TSColor *color = [[TSColor alloc] init];
    color.name = name;
    color.textColor = [UIColor colorWithRed:textC.r green:textC.g blue:textC.b alpha:textC.a];
    color.backgroundColor = [UIColor colorWithRed:bgC.r green:bgC.g blue:bgC.b alpha:bgC.a];
    color.deemphasizedColor = [UIColor colorWithRed:deC.r green:deC.g blue:deC.b alpha:deC.a];
    return color;
}

@end

@implementation TSColors

@synthesize colors=_colors;
@synthesize currentColor=_currentColor;
@synthesize currentColorIndex=_currentColorIndex;

static TSColors *theSharedColors = nil;

+ (void)initialize
{
    // initialize may be called for subclasses, hence this check.
    if (self == [TSColors class]) {
        NSArray *colors = [NSArray arrayWithObjects:
    [TSColor colorWithName:@"White/Black"
                      text:(TSColorStruct){.r=1.0, .g=1.0, .b=1.0, .a=1.0}
                background:(TSColorStruct){.r=0.0, .g=0.0, .b=0.0, .a=1.0}
              deemphasized:(TSColorStruct){.r=2.0/3.0, .g=2.0/3.0, .b=2.0/3.0, .a=1.0}],
    [TSColor colorWithName:@"Black/White"
                      text:(TSColorStruct){.r=0.0, .g=0.0, .b=0.0, .a=1.0}
                background:(TSColorStruct){.r=1.0, .g=1.0, .b=1.0, .a=1.0}
              deemphasized:(TSColorStruct){.r=1.0/3.0, .g=1.0/3.0, .b=1.0/3.0, .a=1.0}],
    [TSColor colorWithName:@"Purple Dark"
                     text:(TSColorStruct){.r=0.5, .g=0.0, .b=0.5, .a=1.0}
               background:(TSColorStruct){.r=0.0, .g=0.0, .b=0.0, .a=1.0}
             deemphasized:(TSColorStruct){.r=0.4, .g=0.0, .b=0.4, .a=1.0}],
                                  nil];
        theSharedColors = [[self alloc] initWithColors:colors];
    }
}

+ (TSColors *)sharedColors
{
    return theSharedColors;
}

+ (TSColor *)theCurrentColor
{
    return [TSColors sharedColors].currentColor;
}

- (id)initWithColors:(NSArray *)colors
{
    self = [super init];
    if (self) {
        _colors = colors;
    }
    return self;
}

- (TSColor *)currentColor
{
    if (_currentColor == nil) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSString *schemeName = [settings stringForKey:@"colorScheme"];
        if (schemeName == nil) {
            _currentColorIndex = 0;
            _currentColor = [self.colors objectAtIndex:0];
        } else {
            _currentColorIndex = 0;
            for (TSColor *color in self.colors) {
                if ([color.name compare:schemeName]==NSOrderedSame) {
                    _currentColor = color;
                    break;
                }
                _currentColorIndex += 1;
            }
            if (_currentColor == nil) {
                // Not found?  Just use the default I guess.
                _currentColorIndex = 0;
                _currentColor = [self.colors objectAtIndex:0];
            }
        }
    }
    return _currentColor;
}

- (NSUInteger)currentColorIndex
{
    // Force this to run first.
    [self currentColor];
    return _currentColorIndex;
}

- (void)configUpdated
{
    // Force lazy update.
    _currentColor = nil;
    _currentColorIndex = 0;
}

- (void)changeCurrentColorToIndex:(NSInteger)index
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    TSColor *color = [_colors objectAtIndex:index];
    [settings setValue:color.name forKey:@"colorScheme"];
    _currentColor = color;
    _currentColorIndex = index;
}

@end
