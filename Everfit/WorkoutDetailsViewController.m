//
//  WorkoutDetailsViewController.m
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "WorkoutDetailsViewController.h"

@interface WorkoutDetailsViewController ()

@end

@implementation WorkoutDetailsViewController
@synthesize workoutTitle;
@synthesize workoutDetails;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return !(UIDeviceOrientationPortraitUpsideDown == interfaceOrientation);
}

- (void)viewDidUnload {
    [self setWorkoutTitle:nil];
    [self setWorkoutDetails:nil];
    [super viewDidUnload];
}
@end
