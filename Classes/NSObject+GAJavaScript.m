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

#import "NSObject+GAJavaScript.h"
#import <objc/runtime.h>

@implementation NSObject (GAJavaScript)

- (NSString *)stringForJavaScript
{
	unsigned int numProps = 0;
	objc_property_t* propList = class_copyPropertyList([self class], &numProps);
	
	NSMutableString* target = [[NSMutableString alloc] initWithCapacity:64];
	[target appendFormat:@"%c", '{'];

	for (unsigned int i = 0; i < numProps; i++)
	{
		const char* propName = property_getName(propList[i]);
		id propValue = [self valueForKey:[NSString stringWithCString:propName encoding:NSASCIIStringEncoding]];
		
		if (i > 0)
			[target appendFormat:@"%c", ','];
		
		[target appendFormat:@"%s: %@", propName, [propValue stringForJavaScript]];
	}
	
	free(propList);
	
	[target appendFormat:@"%c", '}'];
	return [target autorelease];
}

- (BOOL)isJavaScriptTrue
{
	return YES;
}

@end

#pragma mark -

@implementation NSNull (GAJavaScript)

- (NSString *)stringForJavaScript
{
	return @"null";
}

- (BOOL)isJavaScriptTrue
{
	return NO;
}

@end

#pragma mark -

@implementation NSNumber (GAJavaScript)

- (NSString *)stringForJavaScript
{
	const char* numberType = [self objCType];
	
	// If the number contains BOOL, its objC type will be "c"
	if (*numberType == 'c')
		return [self boolValue] ? @"true" : @"false";
	else 
		return [self stringValue]; 
}

- (BOOL)isJavaScriptTrue
{
	// This handles booleans, integers and floats.
	//
	return [self intValue] != 0;
}

@end

#pragma mark -

@implementation NSString (GAJavaScript)

- (NSString *)stringForJavaScript
{
	if ([self length] == 0)
		return @"''";
	
	NSCharacterSet* charsToEscape = [NSCharacterSet escapeForJavaScriptSet];
	
	if ([self rangeOfCharacterFromSet:charsToEscape].location == NSNotFound)
		return [NSString stringWithFormat:@"'%@'", self];
	
	NSMutableString* target = [[NSMutableString alloc] initWithCapacity:[self length] + 4];
	[target appendFormat:@"%c", '\''];
	
	for (NSInteger i = 0; i < [self length]; ++i)
	{
		unichar ch = [self characterAtIndex:i];
		
		if ([charsToEscape characterIsMember:ch])
			[target appendFormat:@"\\%C", ch];
		else 
			[target appendFormat:@"%C", ch];
	}
	
	[target appendFormat:@"%c", '\''];
	return [target autorelease];	
}

- (BOOL)isJavaScriptTrue
{
	return [self length] != 0;
}

@end

#pragma mark -

@implementation NSDate (GAJavaScript)

- (NSString *)stringForJavaScript
{
	return [NSString stringWithFormat:@"new Date(%.0f)", [self timeIntervalSince1970]];
}

@end

#pragma mark -

@implementation NSArray (GAJavaScript)

- (NSString *)stringForJavaScript
{
	NSMutableString* target = [[NSMutableString alloc] initWithCapacity:64];
	[target appendString:@"new Array("];

	for (id elem in self)
	{
		if ([target length] > 10)
			[target appendString:@", "];
		
		[target appendString:[elem stringForJavaScript]];
	}
	
	[target appendString:@")"];
	return target;
}

@end

#pragma mark -

@implementation NSDictionary (GAJavaScript)

- (NSString *)stringForJavaScript
{
	NSArray* allKeys = [self allKeys];
	
	NSMutableString* target = [[NSMutableString alloc] initWithCapacity:64];
	[target appendFormat:@"%c", '{'];
	
	for (NSString* key in allKeys)
	{
		id propValue = [self objectForKey:key];
		[target appendFormat:@"%@: %@, ", key, [propValue stringForJavaScript]];
	}
	
	// Remove the trailing comma
	if ([target characterAtIndex:[target length] - 2] == ',')
		[target deleteCharactersInRange:NSMakeRange([target length] - 2, 2)];
	
	[target appendFormat:@"%c", '}'];
	return [target autorelease];	
}

@end

#pragma mark -

@implementation NSError (GAJavaScript)

- (BOOL)isJavaScriptTrue
{
	return NO;
}

@end

#pragma mark -

@implementation NSCharacterSet (GAJavaScript)

static NSCharacterSet* kNeedsEscapingSet = nil;

+ (id)escapeForJavaScriptSet
{
	if (kNeedsEscapingSet == nil)
		kNeedsEscapingSet = [[NSCharacterSet characterSetWithCharactersInString:@"\'\"\\"] retain];
	
	return kNeedsEscapingSet;
}

@end


