//
//  WorkoutDetailsViewController.h
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *workoutTitle;
@property (weak, nonatomic) IBOutlet UITextView *workoutDetails;
@property (strong, nonatomic) NSString *workoutTitleString;
@property (strong, nonatomic) NSString *workoutDetailsString;

@end
