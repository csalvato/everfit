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
#import "NoteContentViewController.h"
#import "NSString+ENML.h"
#import "Thrift.h"
#import "EvernoteBrain.h"

@interface ExerciseListViewController () <ModalNoteContentViewControllerDelegate>

@property (nonatomic, strong) EDAMNotebook *notebook;
@property (nonatomic, strong) EDAMNote *lastSelectedNote;
@property (nonatomic, strong) NSArray *eventDates; //of NSDates holding the dates of the workout events
@property (nonatomic, strong) NSDictionary *tableEntries; // The key is the NSString for the section header, the value is an NSArray with NSStrings for the entries within that section.
@end

@implementation ExerciseListViewController

@synthesize notebook = _notebook;
@synthesize eventDates = _eventDates;
@synthesize lastSelectedNote = _lastSelectedNote;
@synthesize tableEntries = _tableEntries;

-(NSArray *)eventDates {
    if( !_eventDates ) _eventDates = [NSArray array];
    return _eventDates;
}

-(void)setEventDates:(NSArray *)eventDates {
    if( _eventDates != eventDates ) {
        _eventDates = eventDates;
        //[self.tableView reloadData];
    }
}

-(NSDictionary *)tableEntries{
    if( !_tableEntries ) _tableEntries = [NSDictionary dictionary];
    return _tableEntries;
}

-(void)setTableEntries:(NSDictionary *)tableEntries {
    if( _tableEntries != tableEntries ) {
        _tableEntries = tableEntries;
        [self.tableView reloadData];
    }
}

#pragma mark - Helper Functions

//Sets the initial Evernote Session

- (void) setEvernoteSession {
    // Initial development is done on the sandbox service
    // Change this to @"www.evernote.com" to use the production Evernote service
    NSString *EVERNOTE_HOST = @"sandbox.evernote.com";
    
    // Fill in the consumer key and secret with the values that you received from Evernote
    // To get an API key, visit http://dev.evernote.com/documentation/cloud/
    NSString *CONSUMER_KEY = @"csalvato";
    NSString *CONSUMER_SECRET = @"32d8d1e5f4778b21";
    
    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST 
                              consumerKey:CONSUMER_KEY 
                           consumerSecret:CONSUMER_SECRET];
}



// Creates a new default notebook with the value of REQUIRED_NOTEBOOK_NAME ("Everfit")
-(EDAMNotebook *) createNewNotebookWithName:(NSString *)name {
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
    
    NSDate *date = [NSDate date];
    int32_t currentTime_32 = [date timeIntervalSince1970];
    int64_t currentTime_64 = [date timeIntervalSince1970];
    
    EDAMNotebook *notebook = [[EDAMNotebook alloc] initWithGuid:[NSString generateUUIDString] 
                                                           name:name 
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
    //Hide the refresh button and show a spinner.
    UIBarButtonItem *refreshButton = self.navigationItem.leftBarButtonItem;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    
    EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
    
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        NSUInteger requiredNotebookIndex = [self findIndexOfRequiredNotebook:notebooks];
        // Store the notebook (and create it if necessary)
        if(requiredNotebookIndex == NSNotFound) {
            NSLog(@"Creating Notebook...");
            self.notebook = [self createNewNotebookWithName:REQUIRED_NOTEBOOK_NAME];
        } else {
            NSLog(@"Using Existing Notebook...");
            self.notebook = [notebooks objectAtIndex:requiredNotebookIndex];
        }
        
        [self retrieveFitnessNotesData];
        self.navigationItem.leftBarButtonItem = refreshButton;
        
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
                                                             words:NULL 
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
                                   [self createTableDataFromNotes:list.notes];
                               } else {
                                   NSLog(@"Notes not set?  That is really strange..investigate..");
                               }
                               
                           } 
                           failure:^(NSError *error) {
                               NSLog(@"Failed to retrieve notess");
                           }
     ];
}

// Processes the notes from Evernote to populate the properties that display as entries on the table
-(void) createTableDataFromNotes: (NSArray *)notes {
    //Clear existing table data so that the table is reloaded from Evernote query.
    self.tableEntries = nil;
    self.eventDates = nil;
    
    NSMutableDictionary *tableData = [NSMutableDictionary dictionary];
    for( EDAMNote *note in notes ) {
        //Create Date String for key-value pairing and section titles.
        NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:(note.created/1000)];
        NSString* createdDateAsString = [NSDateFormatter localizedStringFromDate:createdDate 
                                                                       dateStyle:NSDateFormatterShortStyle 
                                                                       timeStyle:NSDateFormatterNoStyle];
        NSMutableArray *arrayForCellEntries;
        if( [[tableData allKeys] containsObject:createdDateAsString] ) {
            arrayForCellEntries = [tableData objectForKey:createdDateAsString];
            
        } else {
            arrayForCellEntries = [NSMutableArray array];
            // Add the date string to an array of dates for ordered section titles.
            NSMutableArray *newEventDatesArray = [NSMutableArray array];
            if(self.eventDates) newEventDatesArray = [self.eventDates mutableCopy];
            
            [newEventDatesArray addObject:createdDateAsString];
            //Make sure the array stays sorted
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" 
                                                                             ascending:NO 
                                                                            comparator:^NSComparisonResult(id obj1, id obj2) {
                                                                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                                                return [[formatter dateFromString:obj1] compare:[formatter dateFromString:obj2]];
                                                                            }
                                                ];
            [newEventDatesArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            self.eventDates = newEventDatesArray;
        }
        
        // Add the note's title to the array created/accessed above to save it.
        [arrayForCellEntries addObject:note];
        
        //Add the object to the dictionary.
        [tableData setObject:arrayForCellEntries forKey:createdDateAsString];
    }
    
    self.tableEntries = [tableData copy];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return !(UIDeviceOrientationPortraitUpsideDown == interfaceOrientation);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEvernoteSession];
    
    // Authenticate the user
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            NSLog(@"Login Failure! :(");
        } else {
            NSLog(@"Login Success! :)");
            [self initializeEvernoteStore];

        } 
    }];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(CGFloat) 0.44 green:(CGFloat) 0.27 blue:(CGFloat) 0.57 alpha:1];
    
}

#define SEGUE_ADD_EXERCISE @"Add Exercise"
#define SEGUE_VIEW_EXERCISE @"View Exercise"
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NoteContentViewController *destinationController = segue.destinationViewController;
    destinationController.delegate = self;
    
    if([segue.identifier isEqualToString:SEGUE_VIEW_EXERCISE]) {
        destinationController.note = self.lastSelectedNote;

        EvernoteNoteStore *noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
        destinationController.noteTitleString = self.lastSelectedNote.title;
        [noteStore getNoteContentWithGuid:self.lastSelectedNote.guid 
                                  success:^(NSString *content) {
                                      [destinationController.loadingNoteSpinner stopAnimating];
                                      destinationController.noteContent.editable = YES;
                                      destinationController.noteContentString = [content convertENMLToTextViewFormat];
                                      NSLog(@"Retrieved Note Content: \n%@", destinationController.noteContentString);
                                  } 
                                  failure:^(NSError *error) {
                                      NSLog(@"Failed to get Note Content...investigate...");
                                  }
         ];
    } else if([segue.identifier isEqualToString:SEGUE_ADD_EXERCISE]) {
        //Nothing particular needs to happen...
    }
}

#pragma mark - Target Action

- (IBAction)refresh:(UIBarButtonItem *)sender {
    [self initializeEvernoteStore];
}


#pragma mark - Table view data source
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.eventDates objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.eventDates count]; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *sectionDate = [self.eventDates objectAtIndex:section];
    NSArray *sectionEntries = [self.tableEntries objectForKey:sectionDate];
    return [sectionEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Exercise Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *sectionData = [self.tableEntries objectForKey:[self.eventDates objectAtIndex:indexPath.section]];
    EDAMNote *noteAtRow = [sectionData objectAtIndex:indexPath.row];
    cell.textLabel.text = noteAtRow.title;
    NSLog( @"Making a cell.." );
    return cell;
}

/*
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
*/
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionData = [self.tableEntries objectForKey:[self.eventDates objectAtIndex:indexPath.section]];
    self.lastSelectedNote = [sectionData objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_VIEW_EXERCISE sender:self];
}

#pragma mark - Modal Note Content View Controller Delegate
-(void)modalNoteContentViewControllerDidFinish:(NoteContentViewController *)sender {
    [self initializeEvernoteStore];
    [self dismissModalViewControllerAnimated:YES];
}

-(EDAMNotebook *)notebookForModalNoteContentViewController {
    return self.notebook;
}

@end
