# Overview

GAJavaScript is a Cocoa Touch library that makes working with JavaScript easier from native code. It has a couple of important design goals:

1. Make working with JavaScript objects and functions more like working with Objective-C objects and methods.
2. Allow native applications on iOS devices to take advantage of JavaScript to support sharing code across platforms or making applications more dynamic.
3. Let native iOS developers take advantage of some of the great web technologies inside WebKit.

- - -

# Classes

JavaScript is accessed from Cocoa Touch using UIWebView. GAJavaScript has the concept of a "script engine", which provides the primary interface to the JavaScript runtime inside the UIWebView. Essentially, the UIWebView is an implementation detail of this library, but you may want to manage the UIWebView instance used by the script engine. 

## GAScriptEngine

This class is the main interface to the library. It takes or creates a UIWebView and prepares it for use with the library. It implements UIWebViewDelegate so that it can load the library's JavaScript file when the WebView is loaded, and it implements support for calling Objective-C methods from JavaScript. It also adds methods to create new objects, either a simple "new Object" or using a constructor function. When you create a new object this way, it's lifetime is tied to the lifetime of the GAScriptObject that is returned, unless you assign the object as a property of another object.

Typically, an iOS application will have one GAScriptEngine instance. You can keep the instance in a globally accessible place, such as the UIApplication delegate, or keep it with the object/view that is managing the hidden UIWebView.

## GAScriptObject

This object provides a wrapper around a JavaScript object in a UIWebView. It provides a KVC view for a JavaScript object, so that you can get and set the object's properties using `[NSObject valueForKey:]` and `[NSObject setValue:forKey:]`, as you would with other Objective-C classes. Only non-function properties are exposed via KVC. 

GAScriptObject handles marshaling of data between the languages. It will handle quoting strings, passing date values, and dealing with sub-objects and arrays.

There are three "callFunction" methods that can be used to call a Function on the object with either no arguments, one argument, or an array of arguments. All the data types supported by the KVC code are supported as function arguments and return types.

GAScriptObject implements NSFastEnumeration so that you can write loops that iterate over the script object's property names and values. 

## UIWebView+GAJavaScript

This category adds accessors to expose several top-level browser objects to Objective-C, including:

* document
* window
* location
* navigator
* localStorage

# Using it

There are unit tests in the /Tests folder that show how to use various features (and they make sure the features work!).

A simple way to get started is to:

1. In your project, add "ga-js-runtime.js" as a bundle resource. This file contains the JavaScript code needed by this library.
2. Create a hidden UIWebView. It can be parented to the app's UIWindow, or a view in a UIViewController.
3. Create a GAScriptEngine and pass the UIWebView to `[GAScriptEngine initWithWebView:]`.
4. Load your HTML+JavaScript into the view. You should load an HTML document that contains/includes all the JavaScript you want to make available to Objective-C code.
5. Now you can access the "document" or "window" object via the UIWebView instance, or create your own objects using `[GAScriptEngine newScriptObject:]`.

Note: If you are using GAJavaScript as a static library, remember to set the `-ObjC` and `-all_load` linker flags so that all the categories are loaded. (You can also use `-force_load` on just libGAJavaScript.a if you have other libraries that don't work well with forced loading.)

## Using your JavaScript

If you have a namespace object in JavaScript (e.g. "mycompany.lib"), you can create a GAScriptObject wrapper for it by using the GAScriptEngine method: `[GAScriptEngine scriptObjectWithReference:@"mycompany.lib"]`.

You can access sub-objects or call functions using the returned GAScriptObject.

One interesting feature of GAJavaScript is the ability to convert arbitrary message invocations on a GAScriptObject into JavaScript calls. This means that you can use "regular" Objective-C calling syntax to call JavaScript, instead of `[GAScriptObject callFunction:]`. This is achieved by GAScriptObject implementing the NSObject methods for invocation forwarding. All that is needed is a definition of the selector and method signature which matches the JavaScript function's signature.

If you look in "GAScriptMethodSignatures.h", you'll see an object that defines a set of selectors for commonly-used JavaScript functions and DOM interfaces. If you include this header in your source that uses script objects, you can invoke these functions directly. For example, say you have a GAScriptObject instance that represents the HTML "document" object:

	// Get the "document" object from the UIWebView
	id document = [myWebView documentJS];
	
	// Get a GAScriptObject that represents the DOM element with id="myelement"
	id myElement = [document getElementById:@"myelement"];
	
	// The above is the same as this, but nicer to read and write
	id myElement2 = [document callFunction:@"getElementById" withObject:@"myelement"];
	
## Handling Errors

GAJavaScript wraps JS function calls with a try/catch, and returns any exceptions as `NSError` objects. Extending the above example:

	// Do something that will cause a JS Error
	id myResult = [document callFunction:@"geetElementById" withObject:@"myelement"];
	
	// Instead of being a GAScriptObject, myResult will be an NSError
	if ([myResult isKindOfClass:[NSError class]])
	{
		NSLog(@"JavaScript call failed: %@", myResult);
	}
	
## Passing Data

GAJavaScript adds a category to `NSObject` that provides a means for any object to implement how it should be serialized when passed into JavaScript. GAJavaScript implements serialization for the following classes:

- `NSString`: Surrounds the string contents with single quotes, and escape single-quote, double-quote, backslash, and control characters.
- `NSNumber`: If it contains a BOOL, the value is "true" or "false". For a number, it's `[NSNumber stringValue]`.
- `NSDate`: Converts to a JS Date using the number of seconds since 1970.
- `NSNull`: "null"
- `NSArray`: Converts to a JS array and call `[NSObject stringForJavaScript]` on each object.
- `NSDictionary`: Converts to a JS object hash with corresponding name/value dictionary pairs.

For all other objects, a JS object is built using the names of the object's defined properties as dictated by the Objective-C runtime. For performance, you may want to implement `[NSObject stringForJavaScript]` on your own types and avoid the need to introspect the class. An easy way to do this is to create an `NSDictionary` with the data you want to pass to JS, and then return `[myDictionary stringForJavaScript]`.

## Receiving Calls

Like other UIWebView wrappers, GAJavaScript supports callbacks from JavaScript to Objective-C. This is accomplished in two ways: you can specify one or more "receiver" objects that can receive JS calls, or you can specify a block to act as a function property on an object.

#### Objective-C
	GAScriptEngine* scriptEngine = [self scriptEngine];
	MyController* myController = [self myController];
	
	// Assuming MyController.h has a method - (void) doSomething:(NSString *)string
	[scriptEngine.receivers addObject:myController];

#### JavaScript
	function callMyController (text) {
		// Invoke [MyController doSomething:]
		GAJavaScript.performSelector('doSomething:', text);
		
		text += ' second time';

		// Invoke [MyController doSomething:] a second time
		GAJavaScript.performSelector('doSomething:', text);		
	}	
	
Note that the call is asynchronous, due to the limitations of UIWebView. So there's no return value to performSelector(). However, you can make multiple invocations, and they will be executed in order.

A solution to the no-return-value problem is to use callback:
#### Objective-C
	-(void)getValueWithCallback:(GAScriptObject*)callback{
		[callback callAsFunctionWithArguments:@[@"Hello"]];
	}
#### JavaScript
	GAJavaScript.performSelector('getValueWithCallback:', function(value){
		// value == "Hello"
	});

And now with blocks:

#### Objective-C
	// Get a reference to window.console
	id console = [myWebView.windowJS valueForKey:@"console"];
	
	// Let's hook "console.log" to call NSLog()
	[console setFunctionForKey:@"log" withBlock:^(NSArray* arguments)
	{
		NSLog(@"UIWebView console: %@", [arguments objectAtIndex:0]);
	}];
	
#### JavaScript
	window.console('This message will go to NSLog');

The above syntax is useful for setting callback functions on XHR objects too.

# GAViewStyling

If you're looking for the code to style UIViews with CSS, it has moved to [another repository](https://github.com/newyankeecodeshop/GAViewStyling). 
