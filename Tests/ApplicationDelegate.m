//
//  ApplicationDelegate.m
//  GAJavaScript
//
//  Created by Andrew on 5/9/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "GAScriptEngine.h"

@implementation ApplicationDelegate

@synthesize scriptEngine = _scriptEngine;

- (void)dealloc
{
    [_scriptEngine release];
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	[super applicationDidFinishLaunching:application];

	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	UIWebView* webView = [[UIWebView alloc] initWithFrame:webFrame];
	webView.tag = 9999;
	webView.hidden = YES;
	
	[window_ addSubview:webView];	

    _scriptEngine = [[GAScriptEngine alloc] initWithWebView:webView];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"TestWebViewContent" ofType:@"html"];
    NSString* html = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	[webView loadHTMLString:html baseURL:nil];
    
    [html release];
}

@end
