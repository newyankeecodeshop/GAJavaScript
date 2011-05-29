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

#import <Foundation/Foundation.h>

/*
 * This category adds support for converting objects into JavaScript values.
 */
@interface NSObject (GAJavaScript)

/*
 * The default implementation for all objects is to return [self description] quoted for JS.
 */
- (NSString *)stringForJavaScript;

/*
 * Returns YES if the object would evaluate to "true" in a JavaScript statement.
 * This means NO is returned if the value is NSNull, empty string, the number zero, or a BOOL NO.
 */
- (BOOL)isJavaScriptTrue;

@end

#pragma mark -

@interface NSNull (GAJavaScript)

- (NSString *)stringForJavaScript;

@end

#pragma mark -

@interface NSNumber (GAJavaScript)

- (NSString *)stringForJavaScript;

@end

#pragma mark -

@interface NSString (GAJavaScript) 

/*
 * Return this string escaped for using in JavaScript. The string will be surrounded by
 * single quotes.
 */
- (NSString *)stringForJavaScript;

@end

#pragma mark -

@interface NSDate (GAJavaScript)

/*
 * Returns a date object using "new Date(time)".
 */
- (NSString *)stringForJavaScript;

@end

#pragma mark -

/*
 * Returns an array object using the constructor that takes the list of values.
 * For each object in the array, we call stringForJavaScript to get the literal value.
 */
@interface NSArray (GAJavaScript)

- (NSString *)stringForJavaScript;

@end

#pragma mark -

/*
 * Returns an object based on the key/value pairs in the dictionary.
 */
@interface NSDictionary (GAJavaScript)

- (NSString *)stringForJavaScript;

@end

#pragma mark -

/*
 * Returns a callback closure for this invocation.
 */
@interface NSInvocation (GAJavaScript)

- (NSString *)stringForJavaScript;

- (void)setArgumentsFromJavaScript:(NSArray *)arguments;

@end

#pragma mark -

/*
 * Returns NO so that errors can be checked via an "if" statement.
 */
@interface NSError (GAJavaScript)

- (BOOL)isJavaScriptTrue;

@end

#pragma mark -

/*
 * The set of characters that need to be quoted in JavaScript strings.
 */
@interface NSCharacterSet (GAJavaScript)

+ (id)escapeForJavaScriptSet;

@end

