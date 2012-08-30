//
//  WorkoutDetailsViewController.m
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "WorkoutDetailsViewController.h"

@interface WorkoutDetailsViewController () <UITextFieldDelegate>

@end

@implementation WorkoutDetailsViewController
@synthesize noteTitle = _noteTitle;
@synthesize noteDetails = _noteDetails;
@synthesize noteTitleString = _noteTitleString;
@synthesize noteDetailsString = _noteDetailsString;
@synthesize isNewNote = _isNewNote;

-(void)setNoteTitleString:(NSString *)noteTitleString {
    _noteTitleString = noteTitleString;
    [self setNoteTitleText:noteTitleString];
}

-(void)setNoteDetailsString:(NSString *)noteDetailsString {
    _noteDetailsString = noteDetailsString;
    [self setNoteDetailsText:noteDetailsString];
}

#pragma mark - Helper Functions
//Sets the text of the workoutDetails Text Field
-(void) setNoteDetailsText:(NSString *)noteDetailsText {
    if(noteDetailsText) self.noteDetails.text = noteDetailsText;
}
//Sets the text of the workoutTitle Text Field
-(void) setNoteTitleText:(NSString *)noteTitleText {
    if(noteTitleText) self.noteTitle.text = noteTitleText;
}


#pragma mark - View Controller Life Cycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return !(UIDeviceOrientationPortraitUpsideDown == interfaceOrientation);
}

-(void)viewDidLoad {
    [self setNoteTitleText:self.noteTitleString];
    [self setNoteDetailsText:self.noteDetailsString];
    self.noteTitle.delegate = self;
}

- (void)viewDidUnload {
    [self setNoteTitle:nil];
    [self setNoteDetails:nil];
    [super viewDidUnload];
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
