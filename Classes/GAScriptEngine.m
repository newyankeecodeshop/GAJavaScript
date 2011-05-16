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

#import "GAScriptEngine.h"
#import "GAScriptObject.h"

@interface GAScriptEngine ()

/*
 * Loads the GAJavaScript runtime into this webview. This method should be called in the
 * UIWebViewDelegate webViewDidFinishLoad: method.
 */
- (void)loadScriptRuntime;

@end

#pragma mark -

@implementation GAScriptEngine

- (id)initWithWebView:(UIWebView *)webView
{
    if ((self = [super init]))
    {
        m_webView = [webView retain];
        m_webView.delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
    [m_webView release];
    
    [super dealloc];
}

- (GAScriptObject *)newScriptObject
{
	NSString* objRef = [m_webView stringByEvaluatingJavaScriptFromString:@"GAJavaScript.makeReference(new Object())"];
	
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:objRef view:m_webView];
	return jsObject;	
}

- (GAScriptObject *)newScriptObject:(NSString *)constructorName
{
    NSString* js = [NSString stringWithFormat:@"GAJavaScript.makeReference(new %@())", constructorName];
	NSString* objRef = [m_webView stringByEvaluatingJavaScriptFromString:js];
	
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:objRef view:m_webView];
	return jsObject;	
}

- (GAScriptObject *)scriptObjectWithReference:(NSString *)reference
{
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:reference view:m_webView];
	return [jsObject autorelease];	
}

- (id)callFunction:(NSString *)functionName
{
	return [[self scriptObjectWithReference:@"window"] callFunction:functionName];
}

- (void)loadScriptRuntime
{
	NSString* scriptFile = [[NSBundle mainBundle] pathForResource:@"ga-js-runtime" ofType:@"js"];
	NSString* scriptData = [NSString stringWithContentsOfFile:scriptFile encoding:NSUTF8StringEncoding error:nil];
	
	[m_webView stringByEvaluatingJavaScriptFromString:scriptData];	
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// Load the GAJavaScript runtime here
	[self loadScriptRuntime];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
                                                 navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


@end
