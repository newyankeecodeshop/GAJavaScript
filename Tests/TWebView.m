//
//  TWebView.m
//  GAJavaScript
//
//  Created by Andrew on 12/12/10.
//  Copyright 2010 Goodale Software. All rights reserved.
//

#import "TWebView.h"
#import "UIWebView+GAJavaScript.h"

@implementation TWebView

- (BOOL)shouldRunOnMainThread 
{
	// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
	return YES;
}

- (void)setUp
{
	UIApplication* app = [UIApplication sharedApplication];
	UIWindow* mainWindow = app.keyWindow;
	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	
	m_webView = [[UIWebView alloc] initWithFrame:webFrame];
	m_webView.delegate = self;
	m_webView.hidden = YES;
	[mainWindow addSubview:m_webView];	
	
	[m_webView loadHTMLString:@"<html><head><title>Test Title</title></head><body><p>Hello World</p></body></html>" 
					  baseURL:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[webView loadScriptRuntime];
	
	[self performSelector:m_curTest];
}

- (void)testDefaultObjects
{
	[self prepare];
	m_curTest = @selector(finishDefaultObjects);
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];	
}

- (void)finishDefaultObjects
{
	NSInteger status = kGHUnitWaitStatusSuccess;
	GAScriptObject* document = [m_webView documentObject];
	
	NSString* title = [document valueForKey:@"title"];
	
	if (![title isEqualToString:@"Test Title"])
		status = kGHUnitWaitStatusFailure;
	
	GAScriptObject* window = [m_webView windowObject];
	
	if (![document isEqual:[window valueForKey:@"document"]])
		status = kGHUnitWaitStatusFailure;
	
	[self notify:status forSelector:@selector(testDefaultObjects)];	
}

@end
