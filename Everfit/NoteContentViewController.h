//
//  WorkoutDetailsViewController.h
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteContentViewController;

@protocol ModalNoteContentViewControllerDelegate
-(void)modalNoteContentViewControllerDidFinish:(NoteContentViewController *)sender;
@end

@interface NoteContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteContent;
@property (strong, nonatomic) NSString *noteTitleString;
@property (strong, nonatomic) NSString *noteContentString;
@property (nonatomic) BOOL isNewNote;
@property (nonatomic, weak) id<ModalNoteContentViewControllerDelegate> delegate;

@end
