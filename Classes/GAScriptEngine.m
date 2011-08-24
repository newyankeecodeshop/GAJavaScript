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
#import "GAScriptEnginePrivate.h"
#import "GAScriptObject.h"
#import "NSObject+GAJavaScript.h"

@interface GAScriptEngine ()

/**
 * Loads the GAJavaScript runtime into this webview. This method should be called in the
 * UIWebViewDelegate webViewDidFinishLoad: method.
 */
- (void)loadScriptRuntime;

- (void)makeLotsaCalls;

- (void)callReceiversForSelector:(SEL)theSelector withArguments:(NSArray *)arguments;

@end

#pragma mark -

@implementation GAScriptEngine

@synthesize webView = m_webView;
@synthesize receivers = m_receivers;

- (id)initWithWebView:(UIWebView *)webView
{
    if ((self = [super init]))
    {
        m_webView = [webView retain];
		m_delegate = [webView delegate];
        m_webView.delegate = self;
        
        m_receivers = [[NSMutableArray alloc] initWithCapacity:4];		
		m_invocations = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    return self;
}

- (id)initWithSuperview:(UIView *)superview delegate:(id<UIWebViewDelegate>)delegate
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    webView.delegate = delegate;
    webView.hidden = YES;
    
    // Setting these will hopefully reduce some memory and CPU consumption in the webview
    //
    webView.userInteractionEnabled = NO;
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    [superview addSubview:webView];
    [webView release];
    
    return [self initWithWebView:webView];
}

- (void)dealloc
{
    [m_webView release];
    [m_document release];
    [m_window release];
    [m_receivers release];
	[m_invocations release];
    
    [super dealloc];
}

- (GAScriptObject *)documentObject
{
    if (m_document == nil)
        m_document = [[GAScriptObject alloc] initForReference:@"document" view:m_webView];
    
    return m_document;
}

- (GAScriptObject *)windowObject
{
    if (m_window == nil)
        m_window = [[GAScriptObject alloc] initForReference:@"window" view:m_webView];
    
    return m_window;
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

- (id)callFunction:(NSString *)functionName withObject:(id)argument
{
	return [[self scriptObjectWithReference:@"window"] callFunction:functionName withObject:argument];
}

#pragma mark Private

- (void)loadScriptRuntime
{
	NSString* scriptFile = [[NSBundle mainBundle] pathForResource:@"ga-js-runtime" ofType:@"js"];
    NSAssert(scriptFile != nil, @"The main bundle is missing the file 'ga-js-runtime.js'!");
    
	NSString* scriptData = [NSString stringWithContentsOfFile:scriptFile 
                                                     encoding:NSUTF8StringEncoding 
                                                        error:nil];
    NSAssert(scriptData != nil, @"The javascript code in ga-js-runtime.js could not be read");
    
	[m_webView stringByEvaluatingJavaScriptFromString:scriptData];	
}

- (void)retainCallArgumentIfNecessary:(id)argument
{
	if ([argument isKindOfClass:[NSInvocation class]] || [argument isKindOfClass:[GAScriptBlockObject class]])
    {
		[m_invocations setObject:argument forKey:[NSNumber numberWithUnsignedInt:[argument hash]]];
    }
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
		NSNumber* invName = [call valueForKey:@"inv"];
        NSArray* arguments = [call valueForKey:@"args"];
		
		if (selName != nil)
		{
			SEL theSelector = NSSelectorFromString(selName);
			[self callReceiversForSelector:theSelector withArguments:arguments];
		}
		else if (invName != nil)
		{
            // Will be an NSInvocation or GAScriptBlockObject
            //
			id invocation = [m_invocations objectForKey:invName];			
			[invocation setArgumentsFromJavaScript:arguments];
			[invocation invoke];
			
//TODO			[m_invocations removeObjectForKey:invName];
		}
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
        
        [inv setSelector:theSelector];
		[inv setArgumentsFromJavaScript:arguments];
        [inv invokeWithTarget:receiver];
        
        // Ignore return values...
        break;
    }    
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([m_delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [m_delegate webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// Load the GAJavaScript runtime before calling the delegate, because the delegate may
	// want to use features of the library.
	[self loadScriptRuntime];
	
    if ([m_delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
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
	if ([m_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
		return [m_delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
	
    // TODO: Only YES for the inital HTML page
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([m_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [m_delegate webView:webView didFailLoadWithError:error];
}

@end

#pragma mark -

@implementation GAScriptBlockObject

- (id)initWithBlock:(void (^)(NSArray *))block
{
    if ((self = [super init]))
    {
        _blockObject = Block_copy(block);        
    }
    
    return self;
}

- (void)dealloc
{
    Block_release(_blockObject);
    
    [_arguments release];
    
    [super dealloc];
}

- (NSString *)stringForJavaScript
{	
	return [NSString stringWithFormat:@"function () { GAJavaScript.invocation(%u, arguments); }", [self hash]];	
}

- (void)setArgumentsFromJavaScript:(NSArray *)arguments
{
    [_arguments release];
    _arguments = [arguments retain];
}

- (void)invoke
{
    void (^theBlock)(NSArray*) = _blockObject;
    theBlock(_arguments);
}

@end
