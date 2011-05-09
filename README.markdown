# Overview

GAJavaScript is a Cocoa Touch library that makes working with JavaScript easier from native code. It has a couple of important design goals:

1. Make working with JavaScript objects and functions more like working with Objective-C objects and methods.
2. Allow native applications on iOS devices to take advantage of JavaScript to support sharing code across platforms or making applications more dynamic.
3. Don't get in the way of developers!

# Classes

JavaScript is accessed from Cocoa Touch using UIWebView. To that end, the main entry point of this library is a category on UIWebView. 

## UIWebView+GAJavaScript

This category adds accessors to access the "document" and "window" objects of the HTML document loaded in the WebView. It also adds methods to create new objects, either a simple "new Object" or using a constructor function. When you create a new object this way, it's lifetime is tied to the lifetime of the GAScriptObject that is returned, unless you assign the object as a property of another object.

## GAScriptObject

This object provides a wrapper around a JavaScript object in a UIWebView. It provides a KVC view for a JavaScript object, so that you can get and set the object's properties using valueForKey: and setValue:forKey:, as you would with other Objective-C classes.

GAScriptObject handles marshaling of data between the languages. It will handle quoting strings, passing dates as "time_t" values, and dealing with sub-objects and arrays.

If you have a namespace object in JavaScript (e.g. "mycompany.lib"), you can create a GAJavaScript wrapper for it by using the GAJavaScript initializer: [[GAJavaScript alloc] initWithReference:@"mycompany.lib" view:myWebView];

There are three "callFunction" methods that can be used to call a Function on the object with either no arguments, one argument, or an array of arguments. All the data types supported by the KVC code are supported as function arguments and return types.

# Using it

There are unit tests in the /Tests folder that show how to use various features (and they make sure the features work!).

A simple way to get started is to:
1. In your project, add "ga-js-runtime.js" as a bundle resource. This file contains the JavaScript code needed by this library.
2. Create a hidden UIWebView. It can be parented to the app's UIWindow, or a view in a UIViewController. You should load an HTML document that contains/includes all the JavaScript you want to make available to Objective-C code.
3. In the [webViewDidFinishLoad:] method of your delegate, call [webView loadJavaScriptRuntime]. This will load "ga-js-runtime.js" into the webView.
4. Now you can access the "document" or "window" object, or start accessing your own global objects.
