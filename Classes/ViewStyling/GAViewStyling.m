//
//  GAViewStyling.m
//  GAJavaScript
//
//  Created by Andrew Goodale on 6/29/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "GAViewStyling.h"

static NSNumberFormatter* kNumFormat = nil;

@implementation UIColor (GAViewStyling)

+ (UIColor *)colorWithCSSColor:(NSString *)cssColor
{
    if (kNumFormat == nil)
        kNumFormat = [[NSNumberFormatter alloc] init];
    
    // Strip off the "rgb(" and ")"
    cssColor = [cssColor substringWithRange:NSMakeRange(4, [cssColor length] - 5)];
    
    NSArray* colorComponents = [cssColor componentsSeparatedByString:@", "];
    CGFloat r = [[kNumFormat numberFromString:[colorComponents objectAtIndex:0]] floatValue] / 255.0;
    CGFloat g = [[kNumFormat numberFromString:[colorComponents objectAtIndex:1]] floatValue] / 255.0;
    CGFloat b = [[kNumFormat numberFromString:[colorComponents objectAtIndex:2]] floatValue] / 255.0;
    
    // Optimize common colors
    //
    if (r == 1.0 && g == 1.0 && b == 1.0)
        return [UIColor whiteColor];
    else if (r == 0.0 && g == 0.0 && b == 0.0)
        return [UIColor blackColor];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

@end

#pragma mark -

@implementation UIFont (GAViewStyling)

+ (UIFont *)fontWithCSSDeclaration:(id)cssDeclaration
{
    if (kNumFormat == nil)
        kNumFormat = [[NSNumberFormatter alloc] init];

    NSString* cssFontFamily = [cssDeclaration valueForKey:@"font-family"];
    //    NSString* cssFontWeight = [cssDeclaration valueForKey:@"font-weight"];
    //    NSString* cssFontStyle = [cssDeclaration valueForKey:@"font-style"];
    
    NSArray* families = [cssFontFamily componentsSeparatedByString:@", "];
    NSString* fontName;
    
    for (NSString* family in families)
    {        
        NSArray* fontNames = [UIFont fontNamesForFamilyName:family];
        
        NSLog(@"Font Family %@ has %@", family, fontNames);
        
        fontName = [fontNames objectAtIndex:0];
        break;
    }
    
    NSString* cssFontSize = [cssDeclaration valueForKey:@"font-size"];
    NSRange pxRange = [cssFontSize rangeOfString:@"px"];
    CGFloat sizeInPixels = [[kNumFormat numberFromString:[cssFontSize substringToIndex:pxRange.location]] floatValue];
    CGFloat fontSize = (sizeInPixels / 160.0) * 72;
    
    return [UIFont fontWithName:fontName size:fontSize];
}

@end
