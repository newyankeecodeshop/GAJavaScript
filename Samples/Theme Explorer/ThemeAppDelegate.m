/*
 Copyright (c) 2011 Andrew Goodale. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are
 permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of
 conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list
 of conditions and the following disclaimer in the documentation and/or other materials
 provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY ANDREW GOODALE "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those of the
 authors and should not be interpreted as representing official policies, either expressed
 or implied, of Andrew Goodale.
 */

#import "ThemeAppDelegate.h"
#import "GAScriptEngine.h"
#import "UIView+GAViewStyling.h"

@implementation ThemeAppDelegate


@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize scriptEngine = _scriptEngine;

+ (ThemeAppDelegate *)sharedAppDelegate
{
    return (ThemeAppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_scriptEngine release];
    
    [super dealloc];
}

- (IBAction)changeTheme:(id)sender
{
    if (_themeChanged)
    {
#if 1
        NSString* curTheme = [_scriptEngine.documentObject valueForKeyPath:@"body.className"];
        
        if ([curTheme isEqualToString:@"red_theme"])
            curTheme = @"blue_theme";
        else
            curTheme = @"red_theme";
        
        [_scriptEngine.documentObject setValue:curTheme forKeyPath:@"body.className"];  
#endif
    }
    
    [_window applyStylesWithScriptEngine:_scriptEngine];
    _themeChanged = YES;
}

- (void)applyStylesToView:(UIView *)view
{
    if (_themeChanged)
    {
        [view applyStylesWithScriptEngine:_scriptEngine];
    }
}

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyWindow];
    
    _scriptEngine = [[GAScriptEngine alloc] initWithSuperview:self.window delegate:self];
    
    NSURL* htmlUrl = [[NSBundle mainBundle] URLForResource:@"styles" withExtension:@"html"];
    [_scriptEngine.webView loadRequest:[NSURLRequest requestWithURL:htmlUrl]];
    
    _themeChanged = NO;
    
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
    NSLog(@"WebView UA %@", [[_scriptEngine windowObject] valueForKeyPath:@"navigator.userAgent"]);
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (_themeChanged)
    {        
        [viewController.view applyStylesWithScriptEngine:_scriptEngine];
    }
}

@end
