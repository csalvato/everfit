//
//  ExerciseListViewControllerTests.m
//  Everfit
//
//  Created by Chris Salvato on 9/4/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "ExerciseListViewControllerTests.h"
#import "ExerciseListViewController.h"
#import "ExerciseListViewControllerExtension.h"


@interface ExerciseListViewControllerTests ()

@property (nonatomic, strong) ExerciseListViewController *elvc;

@end

@implementation ExerciseListViewControllerTests

@synthesize elvc = _elvc;

//Set up before ALL tests
+ (void) setUp {
    [super setUp];
    [self clearContentsOfSandboxAccount];
}

//Set up before Each test
- (void)setUp
{
    [super setUp];
    self.elvc = [[ExerciseListViewController alloc] init];
}

//DOES NOT WORK.  Not properly clearing the contents - probably because its not waiting for the task to complete.  Will just find another way to manually populate a fixture for now.
+ (void) clearContentsOfSandboxAccount {
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
    ExerciseListViewController *elvc = [[ExerciseListViewController alloc] init];
    
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        //Find the required notebook index
        NSUInteger requiredNotebookIndex = [notebooks indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            EDAMNotebook *notebook = obj;
            if ([notebook.name isEqualToString:REQUIRED_NOTEBOOK_NAME]) {
                NSLog(@"Correct Notebook: %@", notebook.name);
                return YES;
            } else {
                NSLog(@"Incorrect Notebook: %@", notebook.name);
                return NO;
            }

        }];
        
        
        // Store the notebook (and create it if necessary)
        if(requiredNotebookIndex == NSNotFound) {
            NSLog(@"Creating Notebook...");
            elvc.notebook = [elvc createNewNotebookWithName:REQUIRED_NOTEBOOK_NAME];
        } else {
            NSLog(@"Using Existing Notebook...");
            //Delete all of the existing notes
            elvc.notebook = [notebooks objectAtIndex:requiredNotebookIndex];
            NSLog(@"Deleting Notes...");
            // Create a query to get all of the notes from the notebook
            EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] initWithOrder:NoteSortOrder_CREATED 
                                                                 ascending:NO 
                                                                     words:NULL 
                                                              notebookGuid:elvc.notebook.guid 
                                                                  tagGuids:nil //TODO: Should eventually find just tags in the Everfit category.
                                                                  timeZone:[[NSTimeZone defaultTimeZone] name] 
                                                                  inactive:NO];
            [noteStore findNotesWithFilter:filter 
                                    offset:0 
                                  maxNotes:[EDAMLimitsConstants EDAM_USER_NOTES_MAX]
                                   success:^(EDAMNoteList *list) {
                                       if( list.notesIsSet ) {
                                           NSLog(@"Successfully retrieved notes");
                                           //Delete all the notes
                                           for( EDAMNote *note in list.notes ) {
                                               [noteStore deleteNoteWithGuid:note.guid 
                                                                     success:^(int32_t usn) {} 
                                                                     failure:^(NSError *error) {}];
                                           }
                                           NSLog(@"Successfully deleted notes");
                                       } else {
                                           NSLog(@"Notes not set?  That is really strange..investigate..");
                                       }
                                       
                                   } 
                                   failure:^(NSError *error) {
                                       NSLog(@"Failed to retrieve notess");
                                   }
             ];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"Error listing notebooks...");
    }];

}

- (void) bootstrapSandboxAccountWithFixtureData {
    
}

//Tear down after each test
- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

//Tear down after ALL tests
+ (void) tearDown {
    [super tearDown];
}
        


- (void)testCreateNotebookWithName
{
    STFail(@"Not Yet Implemented");
}

- (void)testInitializeEvernoteStore
{
    STFail(@"Not Yet Implemented");
}

- (void)testRetrieveFitnessNotesData
{
    STFail(@"Not Yet Implemented");
}

- (void)testCreateTableDataFromNotes
{
    STFail(@"Not Yet Implemented");
}

- (void)testFindIndexOfRequiredNotebook
{
    STFail(@"Not Yet Implemented");
}

- (void)testIsRequiredNotebook
{
    STFail(@"Not Yet Implemented");
}

@end
