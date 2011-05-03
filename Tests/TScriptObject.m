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

#import "TScriptObject.h"
#import "GAScriptObject.h"
#import "UIWebView+GAJavaScript.h"

@implementation TScriptObject

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
	
	m_webView = (UIWebView *) [mainWindow viewWithTag:9999];
	
	if (m_webView == nil)
	{
		m_webView = [[UIWebView alloc] initWithFrame:webFrame];
		m_webView.tag = 9999;
		m_webView.delegate = self;
		m_webView.hidden = YES;
		[mainWindow addSubview:m_webView];	
	}
	
	[m_webView loadHTMLString:@"<html><body><p>Hello World</p></body></html>" baseURL:nil];		
}

- (BOOL)compareValues:(id)gotValue testValue:(id)testValue
{	
	// I don't know why regular isEqual: and compare: don't work for floating point numbers,
	// so I need to compare the decimal values specifically. Weird.
	if ([testValue isKindOfClass:[NSNumber class]])
	{
		NSDecimal dec1 = [testValue decimalValue];
		NSDecimal dec2 = [gotValue decimalValue];
		
		return (NSDecimalCompare(&dec1, &dec2) == NSOrderedSame);
	}
	else if ([testValue isKindOfClass:[NSDate class]])
	{
		// There will be a sub-second difference between the values due to rounding of NSTimeInterval
		// when it's passed into JavaScript. So we validate that the times are within 1 second.
		return ([testValue timeIntervalSinceDate:gotValue] < 1.0);		
	}
	else if (![gotValue isEqual:testValue])
	{
		GHTestLog(@"get/setValue failed for %@", testValue);
		return NO;
	}	
	
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// Load the GAJavaScript runtime here
	[webView loadScriptRuntime];
	
	[self performSelector:m_curTest];
}

- (void)testKeyValueCoding
{
	[self prepare];
	m_curTest = @selector(finishKeyValueCoding);
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];
}

- (void)finishKeyValueCoding
{
	NSArray* kTestValues = [NSArray arrayWithObjects:
							@"abcd",							// String
							@"string 'with' quotes",			// String that needs escaping
							[NSNumber numberWithInt:400000],	// Number (Integer)
							[NSNumber numberWithFloat:0.55555],	// Number (Float)
							[NSNull null],						// Null
							[NSNumber numberWithBool:YES],		// Boolean
							[NSDate date],						// Date
							nil];
	
	NSInteger status = kGHUnitWaitStatusSuccess;
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"location" view:m_webView];

	for (id testValue in kTestValues)
	{
		[jsObject setValue:testValue forKey:@"js_test"];
		id gotValue = [jsObject valueForKey:@"js_test"];
		
		if (![self compareValues:gotValue testValue:testValue])
			status = kGHUnitWaitStatusFailure;
	}
	
	// Test with a character that cannot be in an identifier
	//
	id testValue = @"rgb(1, 2, 3)";
	[jsObject setValue:testValue forKey:@"background-color"];
	id gotValue = [jsObject valueForKey:@"background-color"];
	
	if (![self compareValues:gotValue testValue:testValue])
		status = kGHUnitWaitStatusFailure;	
	
	[self notify:status forSelector:@selector(testKeyValueCoding)];	
	[jsObject release];
}

- (void)testKeyValueCodingWithArrays
{
	[self prepare];
	m_curTest = @selector(finishKeyValueCodingWithArrays);
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];
}

- (void)finishKeyValueCodingWithArrays
{
	NSArray* kTestValues = [NSArray arrayWithObjects:
							@"abcd",							// String
							@"string 'with' quotes",			// String that needs escaping
							[NSNumber numberWithInt:400000],	// Number (Integer)
							[NSNumber numberWithFloat:0.55555],	// Number (Float)
							[NSNull null],						// Null
							[NSNumber numberWithBool:YES],		// Boolean
							[NSDate date],						// Date
							nil];
	
	NSInteger status = kGHUnitWaitStatusSuccess;
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"location" view:m_webView];
	
	[jsObject setValue:kTestValues forKey:@"js_test"];
	NSArray* gotValue = [jsObject valueForKey:@"js_test"];
		
	if (![gotValue isKindOfClass:[NSArray class]])
		status = kGHUnitWaitStatusFailure;

	for (NSInteger i = 0; i < [gotValue count]; ++i)
	{
		if (![self compareValues:[gotValue objectAtIndex:i] testValue:[kTestValues objectAtIndex:i]])
			status = kGHUnitWaitStatusFailure;
	}
	
	[self notify:status forSelector:@selector(testKeyValueCodingWithArrays)];	
	[jsObject release];
}	

- (void)testKeyValueCodingWithDictionary
{
	[self prepare];
	m_curTest = @selector(finishKeyValueCodingWithDictionary);
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];
}

- (void)finishKeyValueCodingWithDictionary
{
	NSDictionary* kTestDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   @"abcd", @"string",							
							   @"string 'with' quotes", @"string_with_quotes",
							   [NSNumber numberWithInt:400000],	    @"integer",
							   [NSNumber numberWithFloat:0.55555],	@"float",
							   [NSNull null],						@"nullprop",
							   [NSNumber numberWithBool:YES],		@"boolprop",
							   [NSDate date],						@"dateprop",
							   nil];
	
	NSInteger status = kGHUnitWaitStatusSuccess;
	GAScriptObject* jsObject = [m_webView newScriptObject];
	
	[jsObject setValue:kTestDict forKey:@"js_test"];
	GAScriptObject* gotValue = [jsObject valueForKey:@"js_test"];
	
	if (![gotValue isKindOfClass:[GAScriptObject class]])
		status = kGHUnitWaitStatusFailure;
	
	for (NSString* key in kTestDict)
	{
		if (![self compareValues:[gotValue valueForKey:key] testValue:[kTestDict objectForKey:key]])
			status = kGHUnitWaitStatusFailure;
	}
	
	[self notify:status forSelector:@selector(testKeyValueCodingWithDictionary)];	
	[jsObject release];
}	

- (void)testAllKeys
{
	[self prepare];
	m_curTest = @selector(finishAllKeys);

	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];
}

- (void)finishAllKeys
{
	NSInteger status = kGHUnitWaitStatusSuccess;

	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"location" view:m_webView];
	NSArray* allKeys = [jsObject allKeys];
		
	if (allKeys == nil)
		status = kGHUnitWaitStatusFailure;
	if ([allKeys count] == 0)
		status = kGHUnitWaitStatusFailure;
	if ([allKeys containsObject:@"hostname"] == NO)
		status = kGHUnitWaitStatusFailure;
	
	[self notify:status forSelector:@selector(testAllKeys)];	
	[jsObject release];
}

- (void)testFastEnumeration
{
	[self prepare];
	m_curTest = @selector(finishFastEnumeration);
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];	
}

- (void)finishFastEnumeration
{
	NSInteger status = kGHUnitWaitStatusFailure;
	
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"location" view:m_webView];

	for (id key in jsObject)
	{
		if ([key isEqual:@"hostname"])
			status = kGHUnitWaitStatusSuccess;
	}

	[self notify:status forSelector:@selector(testFastEnumeration)];	
	[jsObject release];
}

- (void)testCallFunction
{
	[self prepare];
	m_curTest = @selector(finishCallFunction);
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];		
}

- (void)finishCallFunction
{
	NSInteger status = kGHUnitWaitStatusSuccess;

	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"document" view:m_webView];
	id retVal = [jsObject callFunction:@"createElement" withObject:@"strong"];

	if (![retVal isKindOfClass:[GAScriptObject class]])
		status = kGHUnitWaitStatusFailure;
	
	[self notify:status forSelector:@selector(testCallFunction)];	
	[jsObject release];
}

@end
