//
//  EverfitAppDelegate.m
//  Everfit
//
//  Created by Chris Salvato on 8/28/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "EverfitAppDelegate.h"
#import "EvernoteSession.h"
#import "NSString+UUIDString.h"

@implementation EverfitAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setEvernoteSession];
    
    // Authenticate the user
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self.window.rootViewController completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            NSLog(@"Login Failure! :(");
        } else {
            NSLog(@"Login Success! :)");
        } 
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Helper Functions
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
@end
