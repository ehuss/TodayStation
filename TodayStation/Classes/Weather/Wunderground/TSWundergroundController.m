//
//  TSWundergroundController.m
//  TodayStation
//
//  Created by Eric Huss on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSWundergroundController.h"

@implementation TSWundergroundController
@synthesize currentView;
@synthesize currentImageView;
@synthesize moonPhaseView;
@synthesize hiTempView;
@synthesize lowTempView;
@synthesize currentTempView;
@synthesize currentWindView;
@synthesize sunriseView;
@synthesize sunsetView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 
 }*/

- (void)viewDidUnload
{
    [self setCurrentImageView:nil];
    [self setMoonPhaseView:nil];
    [self setHiTempView:nil];
    [self setLowTempView:nil];
    [self setCurrentTempView:nil];
    [self setCurrentWindView:nil];
    [self setSunsetView:nil];
    [self setSunriseView:nil];
    [self setSunsetView:nil];
    [self setCurrentView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
