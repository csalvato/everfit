//
//  ExerciseListViewController.m
//  Everfit
//
//  Created by Chris Salvato on 8/29/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "ExerciseListViewController.h"
#import "EvernoteNoteStore.h"
#import "NSString+UUIDString.h"

@interface ExerciseListViewController ()

@property (nonatomic, strong) EDAMNotebook *notebook;
@property (nonatomic, strong) NSArray *notes;

@end

@implementation ExerciseListViewController

@synthesize notebook = _notebook;
@synthesize notes = _notes;

#define REQUIRED_NOTEBOOK_NAME @"Everfit"
#pragma mark - Helper Functions



// Creates a new default notebook with the value of REQUIRED_NOTEBOOK_NAME ("Everfit")
-(EDAMNotebook *) createNewNotebook {
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
    
    NSDate *date = [NSDate date];
    int32_t currentTime_32 = [date timeIntervalSince1970];
    int64_t currentTime_64 = [date timeIntervalSince1970];
    
    EDAMNotebook *notebook = [[EDAMNotebook alloc] initWithGuid:[NSString generateUUIDString] 
                                                           name:REQUIRED_NOTEBOOK_NAME 
                                              updateSequenceNum:currentTime_32 
                                                defaultNotebook:NO 
                                                 serviceCreated:currentTime_64 
                                                 serviceUpdated:currentTime_64 
                                                     publishing:nil 
                                                      published:NO 
                                                          stack:nil 
                                              sharedNotebookIds:nil 
                                                sharedNotebooks:nil];
    [noteStore createNotebook:notebook 
                      success:^(EDAMNotebook *notebook) {
        NSLog(@"Created Notebook successfully");
    } 
                      failure:^(NSError *error) {
        NSLog(@"Notebook creation failed");
    }];
    
    return notebook;
}

// Checks to see if a notebook exists labelled "Everfit".  If it does not, the notebook will be created.  Once the notebook exists, it is set as a property of the controller for use in generating the table data and the notes are retrieved and stored as a property.
- (void) initializeEvernoteStore {
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        NSUInteger everfitNotebookIndex = [self findIndexOfRequiredNotebook:notebooks];
        // Store the notebook (and create it if necessary)
        if(everfitNotebookIndex == NSNotFound) {
            NSLog(@"Creating Notebook...");
            self.notebook = [self createNewNotebook];
        } else {
            NSLog(@"Using Existing Notebook...");
            self.notebook = [notebooks objectAtIndex:everfitNotebookIndex];
        }
        /*
        // Run a query to get all of the notes from the notebook
        EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] initWithOrder:NoteSortOrder_CREATED 
                                                             ascending:NO words:nil 
                                                          notebookGuid:self.notebook.guid 
                                                              tagGuids:nil //TODO: Should eventually find just tags in the Everfit category.
                                                              timeZone:[[NSTimeZone defaultTimeZone] name] 
                                                              inactive:NO];
        // Get the notes count, and retrieve all of the notes with that count.
        [noteStore findNoteCountsWithFilter:filter 
                                  withTrash:NO
                                    success:^(EDAMNoteCollectionCounts *counts) {
                                        [noteStore findNotesWithFilter:filter 
                                                                offset:0 
                                                              maxNotes:10
                                                               success:^(EDAMNoteList *list) {
                                                                   NSLog(@"Successfully retrieved notes");
                                                               } 
                                                               failure:^(NSError *error) {
                                                                   NSLog(@"Failed to retrieve notess");
                                                               }];
                                    } 
                                    failure:^(NSError *error) {
                                        NSLog(@"Error retrieving notes count");
                                    }];
         */
    } failure:^(NSError *error) {
        NSLog(@"Error listing notebooks...");
    }];
}

// Finds the index of the required notebook in the array of Notebooks returned from Evernote.
-(NSUInteger)findIndexOfRequiredNotebook:(NSArray *) notebooks {
    return [notebooks indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        EDAMNotebook *notebook = obj;
        return [self isRequiredNotebook:notebook];
    }];
}

// Checks to see if a notebook is the required notebook REQUIRED_NOTEBOOK_NAME ("Everfit")
-(BOOL) isRequiredNotebook:(EDAMNotebook *) notebook {
    NSLog(@"Testing notebook...");
    if ([notebook.name isEqualToString:REQUIRED_NOTEBOOK_NAME]) {
        NSLog(@"Correct Notebook: %@", notebook.name);
        return YES;
    } else {
        NSLog(@"Incorrect Notebook: %@", notebook.name);
        return NO;
    }
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeEvernoteStore];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
