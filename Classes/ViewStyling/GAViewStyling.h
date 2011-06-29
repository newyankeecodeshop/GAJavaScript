//
//  GAViewStyling.h
//  GAJavaScript
//
//  Created by Andrew Goodale on 6/29/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (GAViewStyling) 

/**
 * Returns a UIColor for a "rgb(r, g, b)" string.
 */
+ (UIColor *)colorWithCSSColor:(NSString *)cssColor;

@end

#pragma mark -

@interface UIFont (GAViewStyling) 

/**
 * Create a font given a CSSDeclaration containing "font-family", "font-size", "font-weight", "font-style".
 * Any object that supports these key-values will work.
 */
+ (UIFont *)fontWithCSSDeclaration:(id)cssDeclaration;

@end

