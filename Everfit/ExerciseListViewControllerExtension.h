//
//  ExerciseListViewControllerExtension.h
//  Everfit
//
//  Created by Chris Salvato on 9/5/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteNoteStore.h"
#import "NSString+UUIDString.h"
#import "NSString+ENML.h"

@interface ExerciseListViewController ()

@property (nonatomic, strong) EDAMNotebook *notebook;
@property (nonatomic, strong) EDAMNote *lastSelectedNote;
@property (nonatomic, strong) NSArray *eventDates; //of NSDates holding the dates of the workout events
@property (nonatomic, strong) NSDictionary *tableEntries; // The key is the NSString for the section header, the value is an NSArray with NSStrings for the entries within that section.

#pragma mark - Helper Functions
- (void) setEvernoteSession;
- (EDAMNotebook *) createNewNotebookWithName:(NSString *)name;
- (void) initializeEvernoteStore;
- (void) retrieveNotesData;
- (void) createTableDataFromNotes: (NSArray *)notes;
- (NSUInteger)findIndexOfRequiredNotebook:(NSArray *) notebooks;
- (BOOL) isRequiredNotebook:(EDAMNotebook *) notebook;

@end
