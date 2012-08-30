//
//  WorkoutDetailsViewController.m
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "NoteContentViewController.h"

@interface NoteContentViewController () <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation NoteContentViewController
@synthesize noteTitle = _noteTitle;
@synthesize noteContent = _noteContent;
@synthesize noteTitleString = _noteTitleString;
@synthesize noteContentString = _noteContentString;
@synthesize isNewNote = _isNewNote;
@synthesize delegate = _delegate;

-(void)setNoteTitleString:(NSString *)noteTitleString {
    _noteTitleString = noteTitleString;
    [self setNoteTitleText:noteTitleString];
}

-(void)setNoteContentString:(NSString *)noteContentString {
    _noteContentString = noteContentString;
    [self setNoteContentText:noteContentString];
}

#pragma mark - Helper Functions
//Sets the text of the workoutDetails Text Field
-(void) setNoteContentText:(NSString *)noteContentText {
    if(noteContentText) self.noteContent.text = noteContentText;
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
    [self setNoteContentText:self.noteContentString];
    self.noteTitle.delegate = self;
    self.noteContent.delegate = self;
}

- (void)viewDidUnload {
    [self setNoteTitle:nil];
    [self setNoteContent:nil];
    [super viewDidUnload];
}

#pragma mark - Text Field Delegate
-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.noteTitleString = textField.text;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Text View Delegate
-(void)textViewDidChange:(UITextView *)textView{
    self.noteContentString = textView.text;
}

#pragma mark - Target Action
- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate modalNoteContentViewControllerDidFinish:self];
}


@end
