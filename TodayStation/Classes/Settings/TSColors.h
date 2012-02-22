//
//  TSColors.h
//  TodayStation
//
//  Created by Eric Huss on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
} TSColorStruct;

@interface TSColor : NSObject

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *deemphasizedColor;
@property (nonatomic, strong) NSString *name;

+ (id)colorWithName:(NSString *)name
               text:(TSColorStruct)textC
         background:(TSColorStruct)bgC
       deemphasized:(TSColorStruct)deC;
@end

@interface TSColors : NSObject

@property (nonatomic, strong, readonly) NSArray *colors;
@property (nonatomic, weak, readonly) TSColor *currentColor;
@property (nonatomic, assign, readonly) NSUInteger currentColorIndex;

+ (TSColors *)sharedColors;
+ (TSColor *)theCurrentColor;
- (id)initWithColors:(NSArray *)colors;
- (void)configUpdated;
// This updates settings.
- (void)changeCurrentColorToIndex:(NSInteger)index;

@end

void TScolorize(UIView *view);
