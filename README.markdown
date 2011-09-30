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

## UIWebView+GAJavaScript

This category adds accessors to access the "document" and "window" objects of the HTML document loaded in the WebView. You can then use any GAScriptObject functionality on them.

## GAScriptObject

This object provides a wrapper around a JavaScript object in a UIWebView. It provides a KVC view for a JavaScript object, so that you can get and set the object's properties using `[NSObject valueForKey:]` and `[NSObject setValue:forKey:]`, as you would with other Objective-C classes. Only non-function properties are exposed via KVC. 

GAScriptObject handles marshaling of data between the languages. It will handle quoting strings, passing date values, and dealing with sub-objects and arrays.

There are three "callFunction" methods that can be used to call a Function on the object with either no arguments, one argument, or an array of arguments. All the data types supported by the KVC code are supported as function arguments and return types.

GAScriptObject implements NSFastEnumeration so that you can write loops that iterate over the script object's property names and values. 

# Using it

There are unit tests in the /Tests folder that show how to use various features (and they make sure the features work!).

A simple way to get started is to:

1. In your project, add "ga-js-runtime.js" as a bundle resource. This file contains the JavaScript code needed by this library.
2. Create a hidden UIWebView. It can be parented to the app's UIWindow, or a view in a UIViewController.
3. Create a GAScriptEngine and pass the UIWebView to `[GAScriptEngine initWithWebView:]`.
4. Load your HTML+JavaScript into the view. You should load an HTML document that contains/includes all the JavaScript you want to make available to Objective-C code.
5. Now you can access the "document" or "window" object via the GAScriptEngine instance, or create your own objects using `[GAScriptEngine newScriptObject:]`.

## Using your JavaScript

If you have a namespace object in JavaScript (e.g. "mycompany.lib"), you can create a GAScriptObject wrapper for it by using the GAScriptEngine method: `[GAScriptEngine scriptObjectWithReference:@"mycompany.lib"]`.

You can access sub-objects or call functions using the returned GAScriptObject.

One interesting feature of GAJavaScript is the ability to convert arbitrary message invocations on a GAScriptObject into JavaScript calls. This means that you can use "regular" Objective-C calling syntax to call JavaScript, instead of `[GAScriptObject callFunction:]`. This is achieved by GAScriptObject implementing the NSObject methods for invocation forwarding. All that is needed is a definition of the selector and method signature which matches the JavaScript function's signature.

If you look in "GAScriptMethodSignatures.h", you'll see an object that defines a set of selectors for commonly-used JavaScript functions and DOM interfaces. If you include this header in your source that uses script objects, you can invoke these functions directly. For example, say you have a GAScriptObject instance that represents the HTML "document" object:

	// Get the "document" object from the script engine
	id document = [scriptEngine documentObject];
	
	// Get a GAScriptObject that represents the DOM element with id="myelement"
	id myElement = [document getElementById:@"myelement"];
	
	// The above is the same as this, but nicer to read and write
	id myElement2 = [document callFunction:@"getElementById" withObject:@"myelement"];
	
# GAViewStyling

If you're looking for the code to style UIViews with CSS, it has moved to [another repository](https://github.com/newyankeecodeshop/GAViewStyling). 
