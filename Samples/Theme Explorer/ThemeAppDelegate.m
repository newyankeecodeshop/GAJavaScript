//
//  Theme_ExplorerAppDelegate.m
//  Theme Explorer
//
//  Created by Andrew Goodale on 6/23/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "ThemeAppDelegate.h"
#import "GAScriptEngine.h"
#import "UIView+GAViewStyling.h"

@implementation ThemeAppDelegate


@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize scriptEngine = _scriptEngine;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_scriptEngine release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyWindow];
    [self.window setHidden:YES];    // Hide it until we are ready to apply styles
    
    _scriptEngine = [[GAScriptEngine alloc] initWithSuperview:self.window delegate:self];
    
    NSURL* htmlUrl = [[NSBundle mainBundle] URLForResource:@"styles" withExtension:@"html"];
    [_scriptEngine.webView loadRequest:[NSURLRequest requestWithURL:htmlUrl]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.window applyStylesWithScriptEngine:_scriptEngine];
    [self.window setHidden:NO];
    
    NSLog(@"WebView UA %@", [[_scriptEngine windowObject] valueForKeyPath:@"navigator.userAgent"]);
}

@end
