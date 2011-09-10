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

#import "GAScriptBlockObject.h"

@implementation GAScriptBlockObject

+ (id)scriptBlockWithBlock:(GAScriptBlock)block
{
    return [[[GAScriptBlockObject alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(GAScriptBlock)block
{
    if ((self = [super init]))
    {
        _blockObject = [block copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_blockObject release];
    
    [super dealloc];
}

/**
 * Create an invocation reference that uses the address of the block. The block's lifetime needs to be managed
 * by the client, so that this call won't go into nowhere.
 */
- (NSString *)stringForJavaScript
{	
    NSAssert(_blockObject, @"Block for callback cannot be NULL!");
    //    NSLog(@"ScriptBlockObject: function () { GAJavaScript.invocation(%p, arguments); }", (void *)_blockObject);
    
	return [NSString stringWithFormat:@"function () { GAJavaScript.invocation(%p, arguments); }", (void *)_blockObject];	
}

@end

#pragma mark GAScriptObject (Blocks)

@implementation GAScriptObject (Blocks)

- (void)setFunctionForKey:(NSString *)key withBlock:(void(^)(NSArray* arguments))block
{
    GAScriptBlockObject* myBlock = [[GAScriptBlockObject alloc] initWithBlock:block];
    
    [self setValue:myBlock forKey:key];
    
    // Save the block object so that we can keep the block alive while this object is used.
    // The block might be stack-based, which would likely go out-of-scope before the callback
    // is received.
    //
    if (m_blocks == nil)
        m_blocks = [[NSMutableSet alloc] initWithCapacity:4];
        
        [m_blocks addObject:myBlock];
    [myBlock release];
}

@end
