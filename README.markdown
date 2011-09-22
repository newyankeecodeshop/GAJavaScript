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
	
- - -

# UIView Styling 

## GAViewStyling

One of the neat parts about making it easier to access JavaScript is that it becomes easier to access other parts of WebKit. One of those parts is the CSS engine. Inside GAJavaScript is a subsystem, called GAViewStyling, that provides  means to drive UIView cosmetic properties via CSS declarations in an HTML document.

## How it works

Using the UIWebView connected to a GAScriptEngine, load an HTML document that contains HTML markup and CSS. (The stylesheet could be embedded in the HTML, or external.) The HTML markup must provide one or more elements for each style that will be applied. The view styling engine does the following:

1. Starting with a UIView instance, determine the selector uses to query for a DOM element that represents the view. Currently, there are two kinds of selectors used. The class selector (e.g. .UITableView) is used when the view has no tag - the name of the Objective-C class is used as the "class" name. If the view has a nonzero tag, an ID selector (e.g. #tag-3000) is used. This allows you to create styles for specific UIViews.
2. Query the DOM for an element matching the selector.
3. If an element is found, call `window.getComputedStyle()` with that element.
4. Use the resulting CSSStyleDeclaration object to populate UIView properties such as backgroundColor, tintColor, font, etc.
5. Continue processing all of the view's subviews.

GAViewStyling uses a category on UIView and many UIKit view classes. Your own custom view classes can implement methods in the category to change the behavior or apply CSS style information to your custom view properties.

## Example

The "ThemeExplorer" app in the /Samples folder shows how CSS can style various UIKit views and controls. It's built on the Apple "UICatalog" SDK sample, and it applies various (somewhat ugly) "themes" to the table views and various controls. It shows how you can change the overall styles "on the fly", while the app is running.

## Categories

Even if the view styling code is not what you need, you might find some of the categories which can create colors, fonts and gradients from CSS-style strings.

	// Create a UIColor
	UIColor* color = [UIColor colorWithCSSColor:@"rgb(255, 128, 0)"];
	
	// Create a UIFont
    NSDictionary* decl = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Verdana", @"font-family",
                          @"24px", @"font-size",
                          @"bold", @"font-weight", nil];
    UIFont* font = [UIFont fontWithCSSDeclaration:decl];
    
    // Create a gradient layer
    NSString* cssGradient = @"-webkit-gradient(linear, 0% 0%, 0% 100%, from(rgba(217, 217, 217, 0)), to(rgba(0, 0, 0, 0.5)))";

    CAGradientLayer* layer = [CAGradientLayer layer];
    [layer setValuesWithCSSGradient:cssGradient];

The above code uses the categories defined in `GAViewStyling.h`.

