/*
 Copyright (c) 2010-2012 Andrew Goodale. All rights reserved.
 
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
#import "GAScriptObject.h"
#import "GAScriptMethodSignatures.h"
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
	
	m_webView = (UIWebView *) [mainWindow viewWithTag:9999];	
}

- (void)testDefaultObjects
{
	GAScriptObject* document = [m_webView documentJS];
	
	NSString* title = [document valueForKey:@"title"];
	
	GHAssertTrue([title isEqualToString:@"Test Title"], @"Wrong title");
	
	GAScriptObject* window = [m_webView windowJS];
	
	GHAssertTrue([document isEqual:[window valueForKey:@"document"]], @"window.document failed");
    
    GHAssertNotNil([[m_webView navigatorJS] valueForKey:@"userAgent"], @"navigator.userAgent failed");
}

- (void)testGetElements
{
	id document = [m_webView documentJS];

	GAScriptObject* nodeList = [document getElementsByTagName:@"p"];
	NSNumber* length = [nodeList valueForKey:@"length"];
	
	GHAssertTrue([length intValue] == 1, @"NodeList is not object");
	
	GAScriptObject* node = [nodeList callFunction:@"item" withObject:[NSNumber numberWithInt:0]];
	
	NSString* tagName = [node valueForKey:@"tagName"];
	NSString* innerText = [node valueForKey:@"innerText"];

	GHAssertTrue([tagName isEqualToString:@"P"] && [innerText isEqualToString:@"Hello World"],
				 @"Did not get node element");
}

@end
