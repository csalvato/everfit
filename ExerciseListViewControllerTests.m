//
//  ExerciseListViewControllerTests.m
//  Everfit
//
//  Created by Chris Salvato on 9/4/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "ExerciseListViewControllerTests.h"
#import "ExerciseListViewController.h"
#import "EvernoteNoteStore.h"

@implementation ExerciseListViewControllerTests

//Set up before ALL tests
+ (void) setUp {
    [super setUp];
    
}

//Set up before Each test
- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    
    //Load Evernote Fixture
}

- (void) clearContentsOfSandboxAccount {
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
    
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
            self.notebook = [self createNewNotebookWithName:REQUIRED_NOTEBOOK_NAME];
        } else {
            NSLog(@"Using Existing Notebook...");
            //Delete all of the existing notes
            self.notebook = [notebooks objectAtIndex:requiredNotebookIndex];
            NSLog(@"Deleting Notes...");
            
        }
        
        [self retrieveFitnessNotesData];
        self.navigationItem.leftBarButtonItem = refreshButton;
        
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
