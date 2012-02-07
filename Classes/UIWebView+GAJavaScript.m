/*
 Copyright (c) 2010-2012 Andrew Goodale. All rights reserved.
 
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


#import "UIWebView+GAJavaScript.h"
#import "GAScriptEngine.h"
#import "GAScriptObject.h"

@implementation UIWebView (GAJavaScript)

- (GAScriptObject *)documentJS
{
    GAScriptEngine* jsEngine = [GAScriptEngine scriptEngineForView:self];
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"document" withEngine:jsEngine];
	
    return [jsObject autorelease];
}

- (GAScriptObject *)windowJS
{
    GAScriptEngine* jsEngine = [GAScriptEngine scriptEngineForView:self];
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"window" withEngine:jsEngine];
    
	return [jsObject autorelease];
}

- (GAScriptObject *)locationJS
{
    GAScriptEngine* jsEngine = [GAScriptEngine scriptEngineForView:self];
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"location" withEngine:jsEngine];
    
	return [jsObject autorelease];
}

- (GAScriptObject *)localStorageJS
{
    GAScriptEngine* jsEngine = [GAScriptEngine scriptEngineForView:self];
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"localStorage" withEngine:jsEngine];
    
	return [jsObject autorelease];
}

- (GAScriptObject *)navigatorJS
{
    GAScriptEngine* jsEngine = [GAScriptEngine scriptEngineForView:self];
	GAScriptObject* jsObject = [[GAScriptObject alloc] initForReference:@"navigator" withEngine:jsEngine];
    
	return [jsObject autorelease];
}

@end
