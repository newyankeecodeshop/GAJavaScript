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

There are three "callFunction" methods that can be used to call a Function on the object with either no arguments, one argument, or an array of arguments. All the data types supported by the KVC code are supported as function arguments and return types.

# Using it

There are unit tests in the /Tests folder that show how to use various features (and they make sure the features work!).
