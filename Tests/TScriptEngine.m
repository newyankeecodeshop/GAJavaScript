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
#import "GAScriptBlockObject.h"

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

- (void)tearDown
{
    [_engine.receivers removeObject:self];
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

- (void)testCallbackTypedArgs
{
    [self prepare:@selector(callbackTypedArgs:boolArg:intArg:floatArg:)];
    [_engine callFunction:@"testCallbackTypedArgs"];
    
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

- (void)invocationCallback:(NSString *)arg1 andString:(NSString *)arg2 andDate:(NSDate *)arg3
{
//    GHTestLog(@"Callback from Invocation %@ %@ %@", arg1, arg2, arg3);
	
	[self notify:kGHUnitWaitStatusSuccess];
}

- (void)testCallbackAsArgument
{
	[self prepare:@selector(invocationCallback:andString:andDate:)];
	    
	[_engine callFunction:@"testCallbackAsArgument" 
               withObject:[GAScriptBlockObject scriptBlockWithBlock:^(NSArray* arguments) 
    {
        [self invocationCallback:[arguments objectAtIndex:0]
                       andString:[arguments objectAtIndex:1]
                         andDate:[arguments objectAtIndex:2]];
    }]];
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

// We assign the block in a separate method so that our stack-based block will be out-of-scope when the 
// callback happens. We want to test that we are properly copying the block and maintaining it on the heap.
//
- (void)assignBlockToObject:(GAScriptObject *)scriptObj
{    
	[scriptObj setFunctionForKey:@"theBlock" withBlock:^(NSArray *arguments) 
     {         
         [self notify:kGHUnitWaitStatusSuccess];
     }]; 
}

- (void)testObjectWithBlock
{
	[self prepare];

	GAScriptObject* jsObject = [_engine newScriptObject];
    [self assignBlockToObject:jsObject];
    
    [jsObject callFunction:@"theBlock"];

	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
	[jsObject release];
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

- (void)callbackTypedArgs:(NSDate *)dateArg boolArg:(BOOL)boolArg intArg:(NSInteger)intArg floatArg:(CGFloat)floatArg
{
//    NSLog(@"Callback(%@, %c, %d, %f) from JavaScript", dateArg, boolArg, intArg, floatArg);

    NSInteger status = kGHUnitWaitStatusSuccess;
    
    if (![dateArg isKindOfClass:[NSDate class]])
        status = kGHUnitWaitStatusFailure;
    
    if (boolArg != YES || intArg != 200000 || floatArg != 1.5)
        status = kGHUnitWaitStatusFailure;

    [self notify:status];
}

@end
