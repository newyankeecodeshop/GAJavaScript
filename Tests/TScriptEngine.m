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
    [_engine callFunction:@"testCallback"];
}

- (void)testCallbackOneArg
{
    [_engine callFunction:@"testCallbackOneArg"];
}

- (void)testMultipleCallbacks
{
    [_engine callFunction:@"testMultipleCallbacks"];
}

- (void)callbackNoArgs
{
    NSLog(@"Callback() from JavaScript");
}

- (void)callbackOneArg:(NSString *)theArgument
{
    NSLog(@"Callback(%@) from JavaScript", theArgument);
}

@end
