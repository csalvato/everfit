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
@synthesize saveButton = _saveButton;
@synthesize noteTitle = _noteTitle;
@synthesize noteContent = _noteContent;
@synthesize noteTitleString = _noteTitleString;
@synthesize noteContentString = _noteContentString;
@synthesize isNewNote = _isNewNote;
@synthesize delegate = _delegate;

-(void)setNoteTitleString:(NSString *)noteTitleString {
    if(_noteTitleString != noteTitleString && ![_noteTitleString isEqualToString:noteTitleString]) {
        _noteTitleString = noteTitleString;
        [self setNoteTitleText:noteTitleString];   
    }
}

-(void)setNoteContentString:(NSString *)noteContentString {
    if(_noteContentString != noteContentString && ![_noteContentString isEqualToString:noteContentString]) {
        _noteContentString = noteContentString;
        [self setNoteContentText:noteContentString];    
    }
}

#pragma mark - Helper Functions
//Sets the text of the noteContent Text Field
-(void) setNoteContentText:(NSString *)noteContentText {
    if(noteContentText) self.noteContent.text = noteContentText;
}
//Sets the text of the noteTitle Text Field
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
    [self setSaveButton:nil];
    [super viewDidUnload];
}

#pragma mark - Text Field Delegate and Delegate Helper Functions
-(void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)enableSaveButtonIfTitleExists:(NSNotification *) notification {
    UITextField *theTextField = notification.object;
    self.noteTitleString = theTextField.text;
    if([self.noteTitleString length]) {
        [self.saveButton setEnabled:YES];
    } else {
        [self.saveButton setEnabled:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //Register for notifications on text field change so that I can monitor typing (and enable the save button, if necessary)
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(enableSaveButtonIfTitleExists:)
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:textField];
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