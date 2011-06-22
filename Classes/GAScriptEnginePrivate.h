//
//  GAScriptEnginePrivate.h
//  GAJavaScript
//
//  Created by Andrew Goodale on 6/6/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAScriptEngine.h"

@interface GAScriptEngine (Private)

/**
 * Saves (retains) the given argument if it's needed for an asynchronous callback.
 */
- (void)retainCallArgumentIfNecessary:(id)argument;

@end

#pragma mark -

/**
 * Wraps a block so it can be called from JavaScript. Not public right now,
 * but it could be useful for allowing people to use in their own classes.
 */
@interface GAScriptBlockObject : NSObject
{
    id          _blockObject;
    NSArray*    _arguments;
}

- (id)initWithBlock:(void(^)(NSArray* arguments))block;

- (void)setArgumentsFromJavaScript:(NSArray *)arguments;

- (void)invoke;

@end
