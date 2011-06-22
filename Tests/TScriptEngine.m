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

#import "TScriptEngine.h"
#import "GAScriptEngine.h"
#import "GAScriptObject.h"

@implementation TScriptEngine

- (BOOL)shouldRunOnMainThread 
{
	// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
	return YES;
}

- (void)setUp
{
	id appDelegate = [[UIApplication sharedApplication] delegate];
    
    _engine = [appDelegate valueForKey:@"scriptEngine"];
    [_engine.receivers addObject:self];
}

- (void)testCallback
{
	[self prepare:@selector(callbackNoArgs)];
    [_engine callFunction:@"testCallback"];
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];	
}

- (void)testCallbackOneArg
{
	[self prepare:@selector(callbackOneArg)];
    [_engine callFunction:@"testCallbackOneArg"];

	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];	
}

- (void)testMultipleCallbacks
{
    // Multiple callbacks will be invoked, so I'm specifying the last one.
    //
	[self prepare:@selector(callbackOneArg)];
    [_engine callFunction:@"testMultipleCallbacks"];

	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];	
}

- (void)testCallbackAsArgument
{
	[self prepare:@selector(invocationCallback:andString:andDate:)];
	
	NSMethodSignature* sig = [self methodSignatureForSelector:@selector(invocationCallback:andString:andDate:)];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setSelector:@selector(invocationCallback:andString:andDate:)];
	[invocation setTarget:self];
	[_engine callFunction:@"testCallbackAsArgument" withObject:invocation];
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testCallbackWithBlock
{
	[self prepare];

    __block id rightNow = nil;
    
	void (^nowBlock)(NSArray*) = ^ (NSArray* arguments)
	{
		rightNow = [NSDate date];
//		NSLog(@"The date and time is %@", rightNow);
        
        [self notify:kGHUnitWaitStatusSuccess];
	};	
	
	GAScriptObject* jsObject = [_engine newScriptObject];
	
	[jsObject setFunctionForKey:@"nowBlock" withBlock:nowBlock];
    
    [jsObject callFunction:@"nowBlock"];
	[jsObject release];

	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)callbackNoArgs
{
//    NSLog(@"Callback() from JavaScript");
    
    [self notify:kGHUnitWaitStatusSuccess];
}

- (void)callbackOneArg:(NSString *)theArgument
{
//    NSLog(@"Callback(%@) from JavaScript", theArgument);

    NSInteger status = ([theArgument isKindOfClass:[NSString class]]) 
        ? kGHUnitWaitStatusSuccess 
        : kGHUnitWaitStatusFailure;
    [self notify:status];
}

- (void)invocationCallback:(NSString *)arg1 andString:(NSString *)arg2 andDate:(NSDate *)arg3
{
//	NSLog(@"Callback from Invocation %@ %@ %@", arg1, arg2, arg3);
	
	[self notify:kGHUnitWaitStatusSuccess];
}

@end
