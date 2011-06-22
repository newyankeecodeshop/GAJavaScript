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

#import "GAScriptObject.h"
#import "GAScriptMethodSignatures.h"
#import "GAScriptEnginePrivate.h"
#import "NSObject+GAJavaScript.h"

typedef struct /* GAScriptObjectEnumState */
{
    unsigned long	state;
    id *			itemsPtr;
    unsigned long *	mutationsPtr;
    unsigned long	extra_0;
    NSArray *		propNames;
    unsigned long	extra_2;
    unsigned long	extra_3;
    unsigned long	extra_4;
} GAScriptObjectEnumState;

static NSString* const GAJavaScriptErrorDomain = @"GAJavaScriptException";

@interface GAScriptObject ()

- (void)releaseReference;

- (id)convertScriptResult:(NSString *)result reference:(NSString *)reference;

- (NSArray *)arrayFromJavaScript:(NSString *)result reference:(NSString *)reference;

- (NSError *)errorFromJavaScript:(NSString *)result;

- (id)convertArgument:(NSInvocation *)invocation atIndex:(NSInteger)index;

@end

#pragma mark -

@implementation GAScriptObject

static NSNumberFormatter* kNumFormatter = nil;

- (id)initForReference:(NSString *)reference view:(UIWebView *)webView
{
	if ((self = [super init]))
	{
		m_webView = webView;
		m_objReference = [reference retain];
	}
	
	if (kNumFormatter == nil)
		kNumFormatter = [[NSNumberFormatter alloc] init];
	
	return self;
}

- (void)dealloc
{
	[self releaseReference];
	[m_objReference release];
	
	[super dealloc];
}

- (void)releaseReference
{
	if ([m_objReference length] < 18)
		return;
	
	if ([[m_objReference substringToIndex:17] isEqualToString:@"GAJavaScript.ref["])
	{
		NSString* js = [NSString stringWithFormat:@"delete %@", m_objReference];
		[m_webView stringByEvaluatingJavaScriptFromString:js];
	}
}

/*
 * Override the default implementation to handle comparisons with other GAScriptObjects.
 * Note that we can also compare with NSNull easily here. 
 */
- (BOOL)isEqual:(id)object
{
	if (object == self)
		return YES;
	
	if (object == [NSNull null])
	{
		NSString* js = [NSString stringWithFormat:@"%@ == null", m_objReference];
		NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:js];
		
		return [result isEqualToString:@"true"];
	}
	
	if ([object isKindOfClass:[GAScriptObject class]])
	{
		if ([m_objReference isEqualToString:[object stringForJavaScript]])
			return YES;
		
		// The references may be different string values, but still refer to the same object.
		// For example, "document" and "window.document"
		//
		NSString* js = [NSString stringWithFormat:@"%@ == %@", m_objReference, [object stringForJavaScript]];
		NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:js];
		
		return [result isEqualToString:@"true"];		
	}
	
	return [super isEqual:object];
}

/*
 * Override the default implementation and return our object reference.
 */
- (NSString *)stringForJavaScript
{
	return m_objReference;
}

- (NSArray *)allKeys
{	
	NSString* js = [NSString stringWithFormat:@"GAJavaScript.propsOf(%@)", m_objReference];
	NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:js];
	//	NSLog(@"JS allKeys: %@", result);
	
	if ([result length] == 0)	// If the result is '', then we just return an empty array. 
		return [NSArray array];
	
	// Will come back as a comma-delimited list of names
	//
	return [result componentsSeparatedByString:@","];	
}

- (id)callFunction:(NSString *)functionName
{	
	NSString* js = [NSString stringWithFormat:@"GAJavaScript.callFunction(%@.%@, %@)", 
					m_objReference, functionName, m_objReference];
	NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:js];	
	
	return [self convertScriptResult:result reference:m_objReference];
}

- (id)callFunction:(NSString *)functionName withObject:(id)argument
{	
	NSString* js = [NSString stringWithFormat:@"GAJavaScript.callFunction(%@.%@, %@, [%@])", 
					m_objReference, functionName, m_objReference, [argument stringForJavaScript]];
	NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:js];
	
	id scriptEngine = m_webView.delegate;
	[scriptEngine retainCallArgumentIfNecessary:argument];
	
	return [self convertScriptResult:result reference:m_objReference];
}

- (id)callFunction:(NSString *)functionName withArguments:(NSArray *)arguments
{
	NSString* strArgs = [arguments stringForJavaScript];	// "new Array(a,b,c)"
	
	NSString* js = [NSString stringWithFormat:@"GAJavaScript.callFunction(%@.%@, %@, %@)", 
					m_objReference, functionName, m_objReference, strArgs];
	NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:js];	
	
	return [self convertScriptResult:result reference:m_objReference];	
}

#pragma mark GAScriptObject (NSKeyValueCoding)

/*
 * We use the bracket syntax because it supports a wider range of characters in the key names.
 */
- (id)valueForKey:(NSString *)key
{	
	key = [key stringForJavaScript];
	
	NSString* js = [NSString stringWithFormat:@"GAJavaScript.valueToString(%@[%@])", m_objReference, key];
	NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:js];
	
	return [self convertScriptResult:result reference:key];	
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	key = [key stringForJavaScript];

	if (value == nil)
		value = [[NSNull null] stringForJavaScript];		
	else 
		value = [value stringForJavaScript];
	
	NSString* js = [NSString stringWithFormat:@"%@[%@] = %@", m_objReference, key, value];
	[m_webView stringByEvaluatingJavaScriptFromString:js];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
	NSString* js = [NSString stringWithFormat:@"GAJavaScript.valueToString(%@.%@)", m_objReference, keyPath];
	NSString* result = [m_webView stringByEvaluatingJavaScriptFromString:js];
	
	return [self convertScriptResult:result reference:keyPath];		
}

/*
 * Return a true nil value for 'undefined', so that code like this can work:
 *
 * if ([obj valueForKey:@"prop"])
 *     [do something with the value];
 */
- (id)valueForUndefinedKey:(NSString *)key
{
	return nil;
}

#pragma mark Blocks

- (void)setFunctionForKey:(NSString *)key withBlock:(void(^)(NSArray* arguments))block
{
    GAScriptBlockObject* myBlock = [[GAScriptBlockObject alloc] initWithBlock:block];
    
    id scriptEngine = m_webView.delegate;
	[scriptEngine retainCallArgumentIfNecessary:myBlock];

    [self setValue:myBlock forKey:key];
}

#pragma mark Private

- (id)convertScriptResult:(NSString *)result reference:(NSString *)reference
{
	// An empty result means a syntax error or JS exception was thrown.
	if ([result length] == 0)
		return [NSError errorWithDomain:GAJavaScriptErrorDomain code:101 userInfo:nil];
	
	unichar jstype = [result characterAtIndex:0];
	result = [result substringFromIndex:2];
	
	// Objects don't serialize to a string above.		
	if (jstype == 'o')
	{
		GAScriptObject* subObj = [[GAScriptObject alloc] initForReference:result view:m_webView];
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
		return [self arrayFromJavaScript:result reference:reference];
	}
	else if (jstype == 'x')
	{
		return [NSNull null];	// Because 'nil' is for 'undefined'
	}
	else if (jstype == 'u')
	{
		return [self valueForUndefinedKey:result];
	}
	else if (jstype == 'e')		// JavaScript exception
	{
		return [self errorFromJavaScript:result];
	}
	
	return result;	
}

- (NSArray *)arrayFromJavaScript:(NSString *)result reference:(NSString *)reference
{
	NSArray* components = [result componentsSeparatedByString:@","];
	NSMutableArray* retVal = [NSMutableArray arrayWithCapacity:[components count]];
	
	for (NSString* jsvalue in components)
	{
		[retVal addObject:[self convertScriptResult:jsvalue reference:reference]];
	}
	
	return retVal;
}

- (NSError *)errorFromJavaScript:(NSString *)result
{
	GAScriptObject* errObj = [[GAScriptObject alloc] initForReference:result view:m_webView];
	NSArray* errProps = [NSArray arrayWithObjects:@"message", @"sourceURL", @"line", nil];
	NSDictionary* dict = [errObj dictionaryWithValuesForKeys:errProps];
	[errObj release];
	
	return [NSError errorWithDomain:GAJavaScriptErrorDomain code:101 userInfo:dict];	
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{
    NSUInteger count = 0;
	GAScriptObjectEnumState* enumState = (GAScriptObjectEnumState *)state;
	
    // This is the initialization condition, so we'll do one-time setup here.
    // Ensure that you never set state->state back to 0, or use another method to detect initialization
    // (such as using one of the values of state->extra).
    if(enumState->state == 0)
    {
        // We are not tracking mutations, so we'll set state->mutationsPtr to point into one of our extra values,
        // since these values are not otherwise used by the protocol.
        // If your class was mutable, you may choose to use an internal variable that is updated when the class is mutated.
        // state->mutationsPtr MUST NOT be NULL.
        enumState->mutationsPtr = &enumState->extra_0;
		enumState->propNames = [self allKeys];
    }
	
	NSUInteger propCount = [enumState->propNames count];
	
    // Now we provide items, which we track with state->state, and determine if we have finished iterating.
    if (enumState->state < propCount)
    {
        // Set state->itemsPtr to the provided buffer.
        // Alternate implementations may set state->itemsPtr to an internal C array of objects.
        // state->itemsPtr MUST NOT be NULL.
        enumState->itemsPtr = stackbuf;
		
        // Fill in the stack array, either until we've provided all items from the list
        // or until we've provided as many items as the stack based buffer will hold.
        while((enumState->state < propCount) && (count < len))
        {
            // For this sample, we generate the contents on the fly.
            // A real implementation would likely just be copying objects from internal storage.
            enumState->itemsPtr[count] = [enumState->propNames objectAtIndex:count];
            enumState->state++;
            count++;
        }
    }
    else
    {
        // We've already provided all our items, so we signal we are done by returning 0.
        count = 0;
    }
	
    return count;
}

#pragma mark NSObject Forwarding

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [GAScriptMethodSignatures findMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString* selectorName = NSStringFromSelector([anInvocation selector]);
    NSString* functionName;
    NSRange range = [selectorName rangeOfString:@":"];
    
    if (range.length == 0)
        functionName = selectorName;
    else
        functionName = [selectorName substringToIndex:range.location];
        
    NSMethodSignature* methodSig = [anInvocation methodSignature];
    NSUInteger numberOfArgs = [methodSig numberOfArguments];
    id retVal = nil;
    
    if (numberOfArgs == 2)     // Really means zero, since "self" and "_cmd" are the first two.
    {
        retVal = [self callFunction:functionName];
    }
    else if (numberOfArgs == 3)
    {
        id singleArg = [self convertArgument:anInvocation atIndex:2];
        retVal = [self callFunction:functionName withObject:singleArg];
    }
    else if (numberOfArgs > 3)
    {
        NSMutableArray* arguments = [[NSMutableArray alloc] initWithCapacity:numberOfArgs];
        
        for (int i = 2; i < numberOfArgs; ++i)
        {
            id singleArg = [self convertArgument:anInvocation atIndex:i];
            [arguments addObject:singleArg];
        }
        
        retVal = [self callFunction:functionName withArguments:arguments];
        [arguments release];
    }
    
    //TODO: Handle non-Object types.
    //
    if ([methodSig methodReturnLength] > 0)
        [anInvocation setReturnValue:&retVal];
}

- (id)convertArgument:(NSInvocation *)invocation atIndex:(NSInteger)index
{
    void* argValue;
    [invocation getArgument:&argValue atIndex:index];
    
    const char* type = [[invocation methodSignature] getArgumentTypeAtIndex:index];
    
    if (*type == 'c')
        return [NSNumber numberWithBool:(int)argValue];
    
    if (*type == 'i')
        return [NSNumber numberWithInt:(int)argValue];
    
    return (id) argValue;
}

@end
