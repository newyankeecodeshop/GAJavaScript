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

#import "GAScriptObject.h"
#import "GAScriptEngine.h"
#import "GAScriptMethodSignatures.h"
#import "GAScriptBlockObject.h"
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

@interface GAScriptObject ()

- (void)releaseReference;

- (id)convertArgument:(NSInvocation *)invocation atIndex:(NSInteger)index;

- (void)setReturnValue:(NSInvocation *)invocation value:(id)retVal;

@end

#pragma mark -

@implementation GAScriptObject

- (id)initForReference:(NSString *)reference withEngine:(GAScriptEngine *)engine
{
	if ((self = [super init]))
	{
		m_engine = engine;
		m_objReference = [reference copy];
	}
	
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
	if ([m_objReference hasPrefix:@"GAJavaScript.ref["])
	{
		[m_engine evalWithFormat:@"delete %@", m_objReference];
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
		NSString* result = [m_engine evalWithFormat:@"%@ === null", m_objReference];
		
		return [result isEqualToString:@"true"];
	}
	
	if ([object isKindOfClass:[GAScriptObject class]])
	{
		if ([m_objReference isEqualToString:[object stringForJavaScript]])
			return YES;
		
		// The references may be different string values, but still refer to the same object.
		// For example, "document" and "window.document"
		//
		NSString* result = [m_engine evalWithFormat:@"%@ === %@", m_objReference, [object stringForJavaScript]];
		
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
	// Will come back as an array of names
	//
	return [m_engine evalWithFormat:@"GAJavaScript.propsOf(%@)", m_objReference];	
}

- (id)callFunction:(NSString *)functionName
{	
	return [m_engine evalWithFormat:@"GAJavaScript.callFunction(%@.%@, %@)", 
                        m_objReference, functionName, m_objReference];	
}

- (id)callFunction:(NSString *)functionName withObject:(id)argument
{	
	return [m_engine evalWithFormat:@"GAJavaScript.callFunction(%@.%@, %@, [%@])", 
                        m_objReference, functionName, m_objReference, [argument stringForJavaScript]];
}

- (id)callFunction:(NSString *)functionName withArguments:(NSArray *)arguments
{	
	return [m_engine evalWithFormat:@"GAJavaScript.callFunction(%@.%@, %@, %@)", 
                        m_objReference, functionName, m_objReference, [arguments stringForJavaScript]];	
}

- (void)setFunctionForKey:(NSString *)key withBlock:(void(^)(NSArray* arguments))block
{
    GAScriptBlockObject* theBlock = [[GAScriptBlockObject alloc] initWithBlock:block];
    
    [self setValue:theBlock forKey:key];
    
    // Save the block object so that we can keep the block alive while this object is used.
    // The block might be stack-based, which would likely go out-of-scope before the callback
    // is received.
    //
    [m_engine addBlockCallback:theBlock];
    [theBlock release];
}

#pragma mark GAScriptObject (NSKeyValueCoding)

/*
 * We use the bracket syntax because it supports a wider range of characters in the key names.
 */
- (id)valueForKey:(NSString *)key
{	
	return [m_engine evalWithFormat:@"GAJavaScript.valueToString(%@[%@])", 
            m_objReference, [key stringForJavaScript]];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	key = [key stringForJavaScript];

	if (value == nil)
		value = [[NSNull null] stringForJavaScript];		
	else 
		value = [value stringForJavaScript];
	
	[m_engine evalWithFormat:@"%@[%@] = %@", m_objReference, key, value];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
	return [m_engine evalWithFormat:@"GAJavaScript.valueToString(%@.%@)", 
            m_objReference, keyPath];
}

/**
 * Override the default implementation because we can more efficiently let JavaScript dereference the objects.
 * The default implementation would create a lot of temporary GAScriptObject instances as it fetched
 * individual values.
 */
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{    
	if (value == nil)
		value = [[NSNull null] stringForJavaScript];		
	else 
		value = [value stringForJavaScript];
	
	[m_engine evalWithFormat:@"%@.%@ = %@", m_objReference, keyPath, value];    
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
        // Could be a property or a function - GAJavaScript.callFunction() will handle that
        //
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
    
    if ([methodSig methodReturnLength] > 0)
    {
        [self setReturnValue:anInvocation value:retVal];
    }
}

- (id)convertArgument:(NSInvocation *)invocation atIndex:(NSInteger)index
{    
    const char* type = [[invocation methodSignature] getArgumentTypeAtIndex:index];
    
    if (*type == 'c')
    {
        BOOL boolVal;
        [invocation getArgument:&boolVal atIndex:index];
        return [NSNumber numberWithBool:boolVal];
    }
    else if (*type == 'i')
    {
        int intVal;
        [invocation getArgument:&intVal atIndex:index];
        return [NSNumber numberWithInt:intVal];
    }
    else if (*type == 'I')
    {
        unsigned int intVal;
        [invocation getArgument:&intVal atIndex:index];
        return [NSNumber numberWithUnsignedInt:intVal];
    }
    else if (*type == 'l')
    {
        long longVal;
        [invocation getArgument:&longVal atIndex:index];
        return [NSNumber numberWithLong:longVal];
    }
    else if (*type == 'f')
    {
        float floatVal;
        [invocation getArgument:&floatVal atIndex:index];
        return [NSNumber numberWithFloat:floatVal];
    }
    else
    {
        id argObject;
        [invocation getArgument:&argObject atIndex:index]; 
        return argObject;
    }
    
    return nil;
}

- (void)setReturnValue:(NSInvocation *)invocation value:(id)retVal
{
    const char* type = [[invocation methodSignature] methodReturnType];
    
    if (*type == 'c')
    {
        BOOL boolVal = [retVal boolValue];
        [invocation setReturnValue:&boolVal];
    }
    else if (*type == 'i' || *type == 'I')  // Signed/unsigned shouldn't matter since the var size is not different.
    {
        int intVal = [retVal intValue];
        [invocation setReturnValue:&intVal];
    }
    else if (*type == 'l' || *type == 'L')
    {
        long longVal = [retVal longValue];
        [invocation setReturnValue:&longVal];
    }
    else if (*type == 'f')
    {
        float floatVal = [retVal floatValue];
        [invocation setReturnValue:&floatVal];
    }
    else if (*type == '@')
    {
        [invocation setReturnValue:&retVal];
    }
}

@end
