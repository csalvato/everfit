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
@property (nonatomic, strong) NSDictionary *tableEntries; // The key is the NSString for the section header, the value is an NSArray with NSStrings for the entries within that section.
@end

@implementation ExerciseListViewController

@synthesize notebook = _notebook;
@synthesize notes = _notes;
@synthesize tableEntries = _tableEntries;

-(void)setTableEntries:(NSDictionary *)tableEntries {
    if( _tableEntries != tableEntries ) {
        _tableEntries = tableEntries;
        [self.tableView reloadData];
    }
}

- (void)setNotes:(NSArray *)notes {
    _notes = notes;
    [self.tableView reloadData];
    NSLog(@"Data Reloaded on tableView: %@", self.tableView);
}

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
        
     [self retrieveFitnessNotesData];
    
    } failure:^(NSError *error) {
        NSLog(@"Error listing notebooks...");
    }];
}

// Refreshes/retrieve fitness notes data from the Evernote Note Store.
-(void) retrieveFitnessNotesData {
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
    
    // Create a query to get all of the notes from the notebook
    EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] initWithOrder:NoteSortOrder_CREATED 
                                                         ascending:NO 
                                                             words:@"" 
                                                      notebookGuid:self.notebook.guid 
                                                          tagGuids:nil //TODO: Should eventually find just tags in the Everfit category.
                                                          timeZone:[[NSTimeZone defaultTimeZone] name] 
                                                          inactive:NO];
    // Retrieve all of the notes
    [noteStore findNotesWithFilter:filter 
                            offset:0 
                          maxNotes:[EDAMLimitsConstants EDAM_USER_NOTES_MAX]
                           success:^(EDAMNoteList *list) {
                               if( list.notesIsSet ) {
                                   NSLog(@"Successfully retrieved notes");
                                   self.tableEntries = [self createTableDataFromNotes:list.notes];
                               } else {
                                   NSLog(@"Notes not set?  That is really strange..investigate..");
                               }
                               
                           } 
                           failure:^(NSError *error) {
                               NSLog(@"Failed to retrieve notess");
                           }
     ];
}

// Processes the notes from Evernote to create entries on the table
-(NSDictionary *) createTableDataFromNotes: (NSArray *)notes {
    //Parse the dates out of the notes to create the section titles
    NSMutableDictionary *tableData = [NSMutableDictionary dictionary];
    for( EDAMNote *note in notes ) {
        //Get the created date from the note's metadata
        NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:(note.created/1000)];
        NSString* createdDateAsString = [NSDateFormatter localizedStringFromDate:createdDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        //If the date is in the dictionary, get a mutable copy of the NSArray stored for that date key
        NSMutableArray *arrayForCellEntries;
        if( [[tableData allKeys] containsObject:createdDateAsString] ) {
            arrayForCellEntries = [tableData objectForKey:createdDateAsString];
        } else {
            //Else create a new mutable array for the date key.
            arrayForCellEntries = [NSMutableArray array];
        }
            
        
        // Add the note's title to the array created/accessed above to save it.
        [arrayForCellEntries addObject:note.title];
        
        //Add the object to the dictionary.
        [tableData setObject:arrayForCellEntries forKey:createdDateAsString];
    }
    
    return [tableData copy];
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
    // Return the number of sections.
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Exercise Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    EDAMNote *note = [self.notes objectAtIndex:indexPath.row];
    cell.textLabel.text = note.title;
    
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
