//
//  WorkoutDetailsViewController.h
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteDetails;
@property (strong, nonatomic) NSString *noteTitleString;
@property (strong, nonatomic) NSString *noteDetailsString;
@property (nonatomic) BOOL isNewNote;

@end
