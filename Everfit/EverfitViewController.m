//
//  EverfitViewController.m
//  Everfit
//
//  Created by Chris Salvato on 8/28/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "EverfitViewController.h"
#import "EvernoteSession.h"

@interface EverfitViewController ()

@end

@implementation EverfitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            // authentication failed :(
            // show an alert, etc
            NSLog(@"Failure! :(");
        } else {
            // authentication succeeded :)
            // do something now that we're authenticated
            NSLog(@"Success! :)"); 
        } 
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
