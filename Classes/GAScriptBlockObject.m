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

#import "GAScriptBlockObject.h"

@implementation GAScriptBlockObject

@synthesize blockId = m_blockId,
            block = m_block;

+ (id)scriptBlockWithBlock:(GAScriptBlock)block
{
    return [[[GAScriptBlockObject alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(GAScriptBlock)block
{
    if ((self = [super init]))
    {
        m_block = [block copy];
        m_blockId = [[NSString alloc] initWithFormat:@"block-%u", [self hash]];
    }
    
    return self;
}

- (void)dealloc
{
    [m_blockId release];
    [m_block release];
    
    [super dealloc];
}

/**
 * Create an invocation reference that uses the address of the block. The block's lifetime needs to be managed
 * by the client, so that this call won't go into nowhere.
 */
- (NSString *)stringForJavaScript
{	
    NSAssert(m_block, @"Block for callback cannot be NULL!");
    GADebugStr(@"ScriptBlockObject: function () { GAJavaScript.invocation('%@', arguments); }", m_blockId);
    
	return [NSString stringWithFormat:@"function () { GAJavaScript.invocation('%@', arguments); }", m_blockId];	
}

@end

