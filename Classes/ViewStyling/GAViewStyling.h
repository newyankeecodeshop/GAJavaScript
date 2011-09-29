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

#pragma mark -

@interface UIImage (GAViewStyling)

/**
 * Create an image from the main resource bundle or a data URL. For example:
 * url(<bundle_resource.jpg>)
 * url(data:image/jpg;base64,<BASE_64_DATA>)
 *
 */
+ (UIImage *)imageWithCSSURL:(NSString *)cssUrl;

@end

#pragma mark -

/**
 * Returns a size from a CSS declaration that contains two lengths (i.e. "320px 240px").
 * The first length is width (x), the second is height (y). If the string does not have at least two lengths,
 * the function returns CGSizeZero.
 */
CGSize GASizeFromCSSLengths (NSString* cssString);

#pragma mark -

@interface CAGradientLayer (GAViewStyling)

/**
 * Support setting a gradient from the WebKit gradient CSS declaration.
 */
- (void)setValuesWithCSSGradient:(NSString *)cssGradient;

@end
