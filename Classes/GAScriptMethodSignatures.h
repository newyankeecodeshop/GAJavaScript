//
//  GAScriptMethodSignatures.h
//  GAJavaScript
//
//  Created by Andrew on 5/29/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GAScriptMethodSignatures : NSObject 
{
}

/**
 * Adds method signatures from the given class to the list of known signatures.
 */
+ (void)addMethodSignaturesForClass:(Class)clazz;

/**
 * Used by the script object to find a method signature for the given selector.
 */
+ (NSMethodSignature *)findMethodSignatureForSelector:(SEL)aSelector;

#pragma mark Common methods

- (id)item:(NSInteger)index;

#pragma mark DOM Methods

- (id)getElementById:(NSString *)elementId;

- (id)getElementsByTagName:(NSString *)tagName;

- (id)getElementsByClassName:(NSString *)className;

- (id)querySelector:(NSString *)selector;

- (id)querySelectorAll:(NSString *)selector;

#pragma mark View methods

- (id)getComputedStyle:(id)element;

@end
