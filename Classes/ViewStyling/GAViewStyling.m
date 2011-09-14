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

#import "GAViewStyling.h"

@implementation UIColor (GAViewStyling)

+ (UIColor *)colorWithCSSColor:(NSString *)cssColor
{    
    // Strip off the "rgb[a](" and ")". If there's no parens, just return a transparent color.
    //
    NSRange parenRage = [cssColor rangeOfString:@"("];
    
    if (parenRage.location == NSNotFound || [cssColor length] == 0)
        return [UIColor clearColor];
    
    parenRage.location += 1;
    parenRage.length = [cssColor rangeOfString:@")"].location - parenRage.location;
    cssColor = [cssColor substringWithRange:parenRage];
    
    NSArray* colorComponents = [cssColor componentsSeparatedByString:@", "];
    CGFloat r = [[colorComponents objectAtIndex:0] floatValue] / 255.0;
    CGFloat g = [[colorComponents objectAtIndex:1] floatValue] / 255.0;
    CGFloat b = [[colorComponents objectAtIndex:2] floatValue] / 255.0;
    CGFloat a = 1.0;
    
    // Might have been rgba(...)
    //
    if ([colorComponents count] == 4)
        a = [[colorComponents objectAtIndex:3] floatValue] / 255.0;
    
    // Optimize common colors (black, white, transparent)
    //
    if (r == 1.0 && g == 1.0 && b == 1.0)
        return [UIColor colorWithWhite:1.0 alpha:a];
    else if (r == 0.0 && g == 0.0 && b == 0.0)
        return [UIColor colorWithWhite:0.0 alpha:a];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end

#pragma mark -

@implementation UIFont (GAViewStyling)

+ (UIFont *)fontWithCSSDeclaration:(id)cssDeclaration
{
    NSString* cssFontFamily = [cssDeclaration valueForKey:@"font-family"];
    NSString* cssFontWeight = [cssDeclaration valueForKey:@"font-weight"];
    NSString* cssFontStyle = [cssDeclaration valueForKey:@"font-style"];
    
    BOOL wantBold = [cssFontWeight isEqualToString:@"bold"];
    BOOL wantItalic = [cssFontStyle isEqualToString:@"italic"];

    NSArray* families = [cssFontFamily componentsSeparatedByString:@", "];
    NSArray* candidateFontNames = nil;
    
    // First, get the family we want...
    //
    for (NSString* family in families)
    {        
        // Handle the mapping of generic family names
        //
        if ([family caseInsensitiveCompare:@"serif"] == NSOrderedSame)
            family = @"Times";
        else if ([family caseInsensitiveCompare:@"sans-serif"] == NSOrderedSame)
            family = @"Helvetica";
        
        candidateFontNames = [UIFont fontNamesForFamilyName:family];
        
        if ([candidateFontNames count] > 0)
            break;
    }
    
    // Sort the array so the plain font is first
    //
    candidateFontNames = [candidateFontNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) 
    {
        return [obj1 length] - [obj2 length];
    }];
                          
    // Pick the first (plain) font to start with.
    //
    __block NSString* fontName = [candidateFontNames objectAtIndex:0];
        
    if (wantBold || wantItalic)
    {
        __block NSString* marker = (wantBold && !wantItalic) ? @"-Bold" 
            : (wantItalic && !wantBold) ? @"-Italic" : @"-BoldItalic";
        
        [candidateFontNames enumerateObjectsUsingBlock:^void(id testFontName, NSUInteger idx, BOOL *stop) 
        {
            if ([testFontName rangeOfString:marker].location != NSNotFound)
            {
                fontName = testFontName;
                *stop = YES;
            }
        }];
    }
    
    // Font size is in pixels, and we must convert to points.
    //
    NSString* cssFontSize = [cssDeclaration valueForKey:@"font-size"];
    CGFloat sizeInPoints = [cssFontSize integerValue] / [[UIScreen mainScreen] scale];
    
    return [UIFont fontWithName:fontName size:sizeInPoints];
}

@end

/**
 * The input string will be something like "NNNpx NNNpx [other chars]"
 */
CGSize GASizeFromCSSLengths (NSString* cssString)
{
    NSArray* lengths = [cssString componentsSeparatedByString:@"px "];  
    
    if ([lengths count] < 2)
        return CGSizeZero;
    
    CGFloat x = [[lengths objectAtIndex:0] floatValue];
    CGFloat y = [[lengths objectAtIndex:1] floatValue];

    return CGSizeMake(x, y);
}

#pragma mark -

@implementation CAGradientLayer (GAViewStyling)

/**
 * Creates a gradient layer using the CSS specification from WebKit.
 *
 * Example: -webkit-gradient(linear, 0% 100%, 0% 0%, 
 *                           color-stop(0.19, rgb(128, 22, 48)), color-stop(0.6, rgb(224, 36, 74)), color-stop(0.8, rgb(235, 52, 88)))
 */
- (void)setValuesWithCSSGradient:(NSString *)cssGradient
{
    if ([cssGradient length] == 0 || ![cssGradient hasPrefix:@"-webkit-gradient(linear,"])
        return;
        
    NSArray* colorStops = [cssGradient componentsSeparatedByString:@", color-stop("];
    NSMutableArray* colors = [[NSMutableArray alloc] initWithCapacity:[colorStops count]];
    NSMutableArray* locations = [[NSMutableArray alloc] initWithCapacity:[colorStops count]];
    
    for (NSInteger i = 1; i < [colorStops count]; ++i)
    {
        NSString* colorStop = [colorStops objectAtIndex:i];
        [locations addObject:[NSNumber numberWithFloat:[colorStop floatValue]]];
        [colors addObject:(id)[UIColor colorWithCSSColor:colorStop].CGColor];
    }
    
    [self setColors:colors];
    [self setLocations:locations];
    [colors release];
    [locations release];
}

@end

