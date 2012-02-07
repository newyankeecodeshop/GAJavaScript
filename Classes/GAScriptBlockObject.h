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

#import <Foundation/Foundation.h>
#import "GAScriptEngine.h"

typedef void (^GAScriptBlock)(NSArray *);

/**
 * Wraps a block so it can be called from JavaScript. This opbject can be used to pass
 * blocks as arguments to JavaScript function calls.
 */
@interface GAScriptBlockObject : NSObject
{
    NSString*       m_blockId;
    GAScriptBlock   m_block;
}

@property (nonatomic, readonly) NSString*     blockId;
@property (nonatomic, readonly) GAScriptBlock block;

+ (id)scriptBlockWithBlock:(GAScriptBlock)block;

- (id)initWithBlock:(GAScriptBlock)block;

@end

#pragma mark -

/**
 * Add support for functions that are proxies to a block. When the function is called from JavaScript,
 * the block will be invoked.
 */
@interface GAScriptEngine (Blocks)

- (void)addBlockCallback:(GAScriptBlockObject *)blockObject;

@end
