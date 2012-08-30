//
//  WorkoutDetailsViewController.m
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "NoteContentViewController.h"
#import "EvernoteNoteStore.h"
#import "NSString+UUIDString.h"
#import "NSString+ENML.h"

@interface NoteContentViewController () <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation NoteContentViewController
@synthesize topToolbar = _topToolbar;
@synthesize saveButton = _saveButton;
@synthesize noteTitle = _noteTitle;
@synthesize noteContent = _noteContent;
@synthesize noteTitleString = _noteTitleString;
@synthesize noteContentString = _noteContentString;
@synthesize note = _note;
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

-(void)replaceLastBarButtonItemWithSpinner {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];

    if(self.topToolbar) {
        //If it has a toolbar (then it is a modal controller, with last button as save button)
        NSMutableArray *topToolbarItems = [self.topToolbar.items mutableCopy];
        [topToolbarItems removeLastObject];
        [topToolbarItems addObject:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
        self.topToolbar.items = topToolbarItems;
    } else {
        //If it does not have a toolbar (then it is embedded in a nav controller)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    }
    
}

// Creates a new note, with self.noteTitleString and self.noteContentString
-(void) createNewNote {
    [self replaceLastBarButtonItemWithSpinner];
    
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];

    NSDate *date = [NSDate date];
    int64_t currentTime_64 = [date timeIntervalSince1970];

    EDAMNote *note = [[EDAMNote alloc] initWithGuid:[NSString generateUUIDString] 
                                              title:self.noteTitleString 
                                            content:[self.noteContentString convertTextViewFormatToENML]
                                        contentHash:nil 
                                      contentLength:0
                                            created:currentTime_64*1000 
                                            updated:currentTime_64 *1000
                                            deleted:0 
                                             active:YES 
                                  updateSequenceNum:0 
                                       notebookGuid:[[self.delegate notebookForModalNoteContentViewController] guid] 
                                           tagGuids:nil 
                                          resources:nil 
                                         attributes:nil 
                                           tagNames:nil];
    [noteStore createNote:note 
                  success:^(EDAMNote *note) {
                      NSLog(@"Successfully created note!");
                      [self.delegate modalNoteContentViewControllerDidFinish:self];
                  } 
                  failure:^(NSError *error) {
                      NSLog(@"Note creation failed!");
                  }];
}

// Updates an existing note based on the note being viewed
-(void) updateExistingNote {
    UIBarButtonItem *saveButton = self.navigationItem.rightBarButtonItem;
    [self replaceLastBarButtonItemWithSpinner];
    
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
    
    self.note.title = self.noteTitleString;
    self.note.content = [self.noteContentString convertTextViewFormatToENML];
    
    [noteStore updateNote:self.note
                  success:^(EDAMNote *note) {
                      NSLog(@"Note updated successfully!");
                      //If this is modal, can send the signal that we are done
                      [self.delegate modalNoteContentViewControllerDidFinish:self];
                      
                      //If not modal, replace last bar button (spinner) item with Save button
                      self.navigationItem.rightBarButtonItem = saveButton;
                  } 
                  failure:^(NSError *error) {
                      NSLog(@"Note update failed!");
                  }
     ];
    
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
    [self setTopToolbar:nil];
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

- (IBAction)savePressed:(UIBarButtonItem *)sender {
    if(!self.note) {
        [self createNewNote];
    } else {
        [self updateExistingNote];
    }
}



@end
