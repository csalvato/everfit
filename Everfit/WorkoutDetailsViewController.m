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
@synthesize workoutTitle = _workoutTitle;
@synthesize workoutDetails = _workoutDetails;
@synthesize workoutTitleString = _workoutTitleString;
@synthesize workoutDetailsString = _workoutDetailsString;

-(void)setWorkoutTitleString:(NSString *)workoutTitleString {
    _workoutTitleString = workoutTitleString;
    [self setWorkoutTitleText:workoutTitleString];
}

-(void)setWorkoutDetailsString:(NSString *)workoutDetailsString {
    _workoutDetailsString = workoutDetailsString;
    [self setWorkoutDetailsText:workoutDetailsString];
}

#pragma mark - Helper Functions
//Sets the text of the workoutDetails Text Field
-(void) setWorkoutDetailsText:(NSString *)workoutDetailsText {
    if(workoutDetailsText) self.workoutDetails.text = workoutDetailsText;
}
//Sets the text of the workoutTitle Text Field
-(void) setWorkoutTitleText:(NSString *)workoutTitleText {
    if(workoutTitleText) self.workoutTitle.text = workoutTitleText;
}


#pragma mark - View Controller Life Cycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return !(UIDeviceOrientationPortraitUpsideDown == interfaceOrientation);
}

-(void)viewDidLoad {
    [self setWorkoutTitleText:self.workoutTitleString];
    [self setWorkoutDetailsText:self.workoutDetailsString];
}

- (void)viewDidUnload {
    [self setWorkoutTitle:nil];
    [self setWorkoutDetails:nil];
    [super viewDidUnload];
}
@end
