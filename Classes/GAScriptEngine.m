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

- (void)makeLotsaCalls;

- (void)callReceiversForSelector:(SEL)theSelector withArguments:(NSArray *)arguments;

@end

#pragma mark -

@implementation GAScriptEngine

@synthesize receivers = m_receivers;

- (id)initWithWebView:(UIWebView *)webView
{
    if ((self = [super init]))
    {
        m_webView = [webView retain];
		m_delegate = [webView delegate];
        m_webView.delegate = self;
        
        m_receivers = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    return self;
}

- (void)dealloc
{
    [m_webView release];
    [m_receivers release];
    
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

- (void)makeLotsaCalls
{
    id calls = [self scriptObjectWithReference:@"GAJavaScript.calls"];
    NSNumber* numCalls = [calls valueForKey:@"length"];
    calls = [calls callFunction:@"splice" 
                  withArguments:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], numCalls, nil]];
    
    for (NSInteger i = 0; i < [calls count]; ++i)
    {
        id call = [calls objectAtIndex:i];
        
        NSString* selName = [call valueForKey:@"sel"];
        NSArray* arguments = [call valueForKey:@"args"];
        SEL theSelector = NSSelectorFromString(selName);
       
        [self callReceiversForSelector:theSelector withArguments:arguments];
    }    
}

- (void)callReceiversForSelector:(SEL)theSelector withArguments:(NSArray *)arguments
{
    // The first argument is the selector name, so ignore it
    //
    arguments = [arguments subarrayWithRange:NSMakeRange(1, [arguments count] - 1)];
    
    for (id receiver in self.receivers)
    {
        if (![receiver respondsToSelector:theSelector])
            continue;
        
        NSMethodSignature* methodSig = [receiver methodSignatureForSelector:theSelector];
        NSInvocation* inv = [NSInvocation invocationWithMethodSignature:methodSig];
        NSInteger argIndex = 2;
        
        for (id arg in arguments)
            [inv setArgument:&arg atIndex:argIndex++];
        
        [inv setSelector:theSelector];
        [inv invokeWithTarget:receiver];
        
        // Ignore return values...
        break;
    }    
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[m_delegate webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// Load the GAJavaScript runtime before calling the delegate, because the delegate may
	// want to use features of the library.
	[self loadScriptRuntime];
	
	[m_delegate webViewDidFinishLoad:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
                                                 navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* theUrl = [request URL];
    
    if ([[theUrl scheme] isEqualToString:@"ga-js"])
    {
        if ([[theUrl resourceSpecifier] isEqualToString:@"makeLotsaCalls"])
        {
            [self makeLotsaCalls];
        }
        
        return NO;
    }
    
	// Let the delegate handle it if we have one.
	if (m_delegate)
		return [m_delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
	
    // TODO: Only YES for the inital HTML page
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[m_delegate webView:webView didFailLoadWithError:error];
}

@end
