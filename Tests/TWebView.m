/*
 Copyright (c) 2010 Andrew Goodale. All rights reserved.
 
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
