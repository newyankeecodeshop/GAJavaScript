/*
 Copyright (c) 2011-2012 Andrew Goodale. All rights reserved.
 
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
#import "GAScriptBlockObject.h"
#import "NSObject+GAJavaScript.h"

static NSNumberFormatter* kNumFormatter = nil;

static NSString* const GAJavaScriptErrorDomain = @"GAJavaScriptException";
static NSString* const GAJavaScriptErrorName   = @"JSErrorName";
static NSString* const GAJavaScriptErrorSource = @"JSErrorSource";
static NSString* const GAJavaScriptErrorLine   = @"JSErrorLine";

@interface GAScriptEngine ()

- (id)convertScriptResult:(NSString *)result;

- (NSArray *)arrayFromJavaScript:(NSString *)result;

- (NSError *)errorFromJavaScript:(NSString *)result;

/**
 * Loads the GAJavaScript runtime into this webview. This method should be called in the
 * UIWebViewDelegate webViewDidFinishLoad: method.
 */
- (void)loadScriptRuntime;

- (BOOL)scriptRuntimeIsLoaded;

- (void)makeLotsaCalls;

- (void)callReceiversForSelector:(SEL)theSelector withArguments:(NSArray *)arguments;

@end

#pragma mark -

@implementation GAScriptEngine

@synthesize webView = m_webView;
@synthesize receivers = m_receivers;

+ (GAScriptEngine *)scriptEngineForView:(UIWebView *)webView
{
    return (GAScriptEngine *)webView.delegate;
}

- (id)initWithWebView:(UIWebView *)webView
{
    if ((self = [super init]))
    {
        m_webView = [webView retain];
		m_delegate = [webView delegate];
        m_webView.delegate = self;
        
        m_receivers = [[NSMutableArray alloc] initWithCapacity:4];		
    }
    
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        kNumFormatter = [[NSNumberFormatter alloc] init];
    });
	
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
    [m_receivers release];
    [m_blocks release];
 
    [super dealloc];
}

- (GAScriptObject *)newScriptObject
{
	NSString* objRef = [m_webView stringByEvaluatingJavaScriptFromString:@"GAJavaScript.makeReference(new Object())"];
	
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:objRef withEngine:self];
	return jsObject;	
}

- (GAScriptObject *)newScriptObject:(NSString *)constructorName
{
    NSString* js = [NSString stringWithFormat:@"GAJavaScript.makeReference(new %@())", constructorName];
	NSString* objRef = [m_webView stringByEvaluatingJavaScriptFromString:js];
	
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:objRef withEngine:self];
	return jsObject;	
}

- (GAScriptObject *)scriptObjectWithReference:(NSString *)reference
{
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:reference withEngine:self];
	return [jsObject autorelease];	
}

- (id)evalWithFormat:(NSString *)format, ...
{
    va_list args;
    
    va_start(args, format);
    NSString* script = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:script];
    [script release];
    
    if (![format hasPrefix:@"GAJavaScript."])
        return result;
    
    // The result will be encoded using the scheme in GAJavaScript.valueToString()
    //
    return [self convertScriptResult:result];
}

/**
 * Call functions at global (window) scope.
 */
- (id)callFunction:(NSString *)functionName
{
	return [self evalWithFormat:@"GAJavaScript.callFunction(%@, window)", functionName];	
}

- (id)callFunction:(NSString *)functionName withObject:(id)argument
{
    if ([argument isKindOfClass:[GAScriptBlockObject class]])
    {
        [self addBlockCallback:argument];
    }
	return [self evalWithFormat:@"GAJavaScript.callFunction(%@, window, [%@])", 
                        functionName, [argument stringForJavaScript]];	
}

- (id)callFunction:(NSString *)functionName withArguments:(NSArray *)arguments
{	
    for (id arg in arguments)
    {
        if ([arg isKindOfClass:[GAScriptBlockObject class]])
            [self addBlockCallback:arg];        
    }
	return [self evalWithFormat:@"GAJavaScript.callFunction(%@, window, %@)", 
                        functionName, [arguments stringForJavaScript]];		
}

#pragma mark Data Conversion

- (id)convertScriptResult:(NSString *)result 
{
	// An empty result means a syntax error or JS exception was thrown.
	if ([result length] == 0)
		return [NSError errorWithDomain:GAJavaScriptErrorDomain code:101 userInfo:nil];
	    
	unichar jstype = [result characterAtIndex:0];
	result = [result substringFromIndex:2];
	
	// Objects don't serialize to a string above.		
	if (jstype == 'o')
	{
		GAScriptObject* subObj = [[GAScriptObject alloc] initForReference:result withEngine:self];
		return [subObj autorelease];
	}
	else if (jstype == 'd')
	{
		NSNumber* millisecsSince1970 = [kNumFormatter numberFromString:result];
		return [NSDate dateWithTimeIntervalSince1970:[millisecsSince1970 doubleValue] / 1000];
	}
	else if (jstype == 'n')
	{
		return [kNumFormatter numberFromString:result];
	}
	else if (jstype == 'b')
	{
		return [NSNumber numberWithBool:[result isEqualToString:@"true"]];
	}
	else if (jstype == 'a')
	{		
		return [self arrayFromJavaScript:result];
	}
	else if (jstype == 'x')
	{
		return [NSNull null];	// Because 'nil' is for 'undefined'
	}
	else if (jstype == 'u')
	{
		return nil;
	}
	else if (jstype == 'e')		// JavaScript exception
	{
		return [self errorFromJavaScript:result];
	}
	
	return result;	
}

- (NSArray *)arrayFromJavaScript:(NSString *)result
{
	NSArray* components = [result componentsSeparatedByString:@"\f"];
	NSMutableArray* retVal = [NSMutableArray arrayWithCapacity:[components count]];
	
	for (NSString* jsvalue in components)
	{
		[retVal addObject:[self convertScriptResult:jsvalue]];
	}
	
	return retVal;
}

- (NSError *)errorFromJavaScript:(NSString *)result
{
	GAScriptObject* errObj = [[GAScriptObject alloc] initForReference:result withEngine:self];
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [errObj valueForKey:@"name"], GAJavaScriptErrorName,
                          [errObj valueForKey:@"message"], NSLocalizedDescriptionKey,
                          [errObj valueForKey:@"sourceURL"], GAJavaScriptErrorSource,
                          [errObj valueForKey:@"line"], GAJavaScriptErrorLine, nil];
	[errObj release];
	
	return [NSError errorWithDomain:GAJavaScriptErrorDomain code:101 userInfo:dict];	
}

#pragma mark Blocks

- (void)addBlockCallback:(GAScriptBlockObject *)blockObject
{
    if (m_blocks == nil)
        m_blocks = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    [m_blocks setObject:blockObject.block forKey:blockObject.blockId];
}

#pragma mark Private

- (void)loadScriptRuntime
{
    if ([self scriptRuntimeIsLoaded])   // Don't re-evaluate the runtime javascript, because it will destroy all existing object references.
        return;
        
	NSString* scriptFile = [[NSBundle mainBundle] pathForResource:@"ga-js-runtime" ofType:@"js"];
    NSAssert(scriptFile != nil, @"The main bundle is missing the file 'ga-js-runtime.js'!");
    
	NSString* scriptData = [NSString stringWithContentsOfFile:scriptFile 
                                                     encoding:NSUTF8StringEncoding 
                                                        error:nil];
    NSAssert(scriptData != nil, @"The javascript code in ga-js-runtime.js could not be read");
    
	[m_webView stringByEvaluatingJavaScriptFromString:scriptData];	
}

- (BOOL)scriptRuntimeIsLoaded
{
    return [[m_webView stringByEvaluatingJavaScriptFromString:@"typeof GAJavaScript"] isEqualToString:@"object"];
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
		
		if (selName != nil && [selName isKindOfClass:[NSString class]])
		{
			SEL theSelector = NSSelectorFromString(selName);
			[self callReceiversForSelector:theSelector withArguments:arguments];
		}
		else if (invName != nil && [invName isKindOfClass:[NSString class]])
		{
            // Will be the ID of a block object
            //
            GAScriptBlock theBlock = [m_blocks objectForKey:invName];
            
            if (theBlock)
                theBlock(arguments);
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
	
    // Reloading is fine otherwise - we'll make sure the script engine is loaded in the new page.
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([m_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [m_delegate webView:webView didFailLoadWithError:error];
}

@end
