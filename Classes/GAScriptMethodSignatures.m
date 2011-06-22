//
//  GAScriptMethodSignatures.m
//  GAJavaScript
//
//  Created by Andrew on 5/29/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "GAScriptMethodSignatures.h"

static NSMutableSet* s_classes = nil;

@implementation GAScriptMethodSignatures

+ (void)addMethodSignaturesForClass:(Class)clazz
{
    if (s_classes == nil)
    {
        s_classes = [[NSMutableSet alloc] initWithCapacity:16];
		[s_classes addObject:[GAScriptMethodSignatures class]];
	}
	
	[s_classes addObject:clazz];
}

+ (NSMethodSignature *)findMethodSignatureForSelector:(SEL)aSelector
{
    if (s_classes == nil)
    {
        s_classes = [[NSMutableArray alloc] initWithCapacity:16];
		[s_classes addObject:[GAScriptMethodSignatures class]];
	}
    
    // If performance becomes a concern, we can build a cache of these mappings.
    //
    for (Class aClass in s_classes)
    {
        if ([aClass instancesRespondToSelector:aSelector])
            return [aClass instanceMethodSignatureForSelector:aSelector];
    }
	
    return nil;
}

#pragma mark DOM Methods

- (id)getElementById:(NSString *)elementId
{
	return nil;
}

- (id)getElementsByTagName:(NSString *)tagName
{
	return nil;
}

- (id)item:(NSInteger)index
{
    return nil;
}

@end
