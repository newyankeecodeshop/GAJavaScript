//
//  ApplicationDelegate.m
//  GAJavaScript
//
//  Created by Andrew on 5/9/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "UIWebView+GAJavaScript.h"

@implementation ApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	[super applicationDidFinishLaunching:application];

	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	UIWebView* webView = [[UIWebView alloc] initWithFrame:webFrame];
	webView.tag = 9999;
	webView.delegate = self;
	webView.hidden = YES;
	
	[window_ addSubview:webView];	

	[webView loadHTMLString:@"<html><head><title>Test Title</title></head><body><p>Hello World</p></body></html>" 
					baseURL:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// Load the GAJavaScript runtime here
	[webView loadScriptRuntime];
}

@end
