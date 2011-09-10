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

#import <UIKit/UIKit.h>

@class GAScriptObject;

/**
 * The primary interface for interacting with JavaScript, via a UIWebView. The web view's delegate will
 * be set to the script engine, to facilitate the loading of the required JavaScript.
 */
@interface GAScriptEngine : NSObject <UIWebViewDelegate>
{
@private
    UIWebView*				m_webView;
	id<UIWebViewDelegate>	m_delegate;
    
    GAScriptObject*         m_document;
    GAScriptObject*         m_window;
    
    NSMutableArray*			m_receivers;
}

/**
 * The UIWebView that provides the JavaScript runtime for this script engine.
 */
@property (nonatomic, readonly) UIWebView*      webView;

/**
 * A reference to the "document" object for this UIWebView.
 */
@property (nonatomic, readonly) GAScriptObject* documentObject;

/**
 * A reference to the "window" object for thi UIWebView.
 */
@property (nonatomic, readonly) GAScriptObject* windowObject;

/**
 * An array of objects that take callbacks from JavaScript code.
 */
@property (nonatomic, retain) NSMutableArray*   receivers;

/**
 * The designated initializer.
 */
- (id)initWithWebView:(UIWebView *)webView;

/**
 * Initializer that creates a hidden UIWebView inside the provided view. Use this initializer
 * if you don't care about how the webView is created. After this method, you should call one of the "load"
 * methods to get an HTML document loaded.
 */
- (id)initWithSuperview:(UIView *)superview delegate:(id<UIWebViewDelegate>)delegate;

/*
 * Creates a new (empty) object 
 */
- (GAScriptObject *)newScriptObject;

/*
 * Creates a new object using the constructor function.
 */
- (GAScriptObject *)newScriptObject:(NSString *)constructorName;

/*
 * Returns a script object bound to the given reference. The script object will have 
 * a "weak" reference to the JavaScript object
 */
- (GAScriptObject *)scriptObjectWithReference:(NSString *)reference;

/*
 * Call a function at global (window) scope.
 */
- (id)callFunction:(NSString *)functionName;

/*
 * Call a function at global scope with a single argument.
 */
- (id)callFunction:(NSString *)functionName withObject:(id)argument;

@end
