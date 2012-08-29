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
