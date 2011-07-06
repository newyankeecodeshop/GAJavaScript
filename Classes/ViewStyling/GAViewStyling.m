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
    
    // Strip off the "rgb[a](" and ")"
    //
    NSRange parenRage = [cssColor rangeOfString:@"("];
    cssColor = [cssColor substringWithRange:NSMakeRange(parenRage.location + 1, 
                                                        [cssColor length] - (parenRage.location + 2))];
    
    NSArray* colorComponents = [cssColor componentsSeparatedByString:@", "];
    CGFloat r = [[kNumFormat numberFromString:[colorComponents objectAtIndex:0]] floatValue] / 255.0;
    CGFloat g = [[kNumFormat numberFromString:[colorComponents objectAtIndex:1]] floatValue] / 255.0;
    CGFloat b = [[kNumFormat numberFromString:[colorComponents objectAtIndex:2]] floatValue] / 255.0;
    CGFloat a = 1.0;
    
    // Might have been rgba(...)
    //
    if ([colorComponents count] == 4)
        a = [[kNumFormat numberFromString:[colorComponents objectAtIndex:3]] floatValue] / 255.0;
    
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
    cssFontSize = [cssFontSize substringToIndex:[cssFontSize rangeOfString:@"px"].location];
    CGFloat sizeInPixels = [[kNumFormat numberFromString:cssFontSize] floatValue];
    CGFloat fontSize = (sizeInPixels / 160.0) * 72;
    
    return [UIFont fontWithName:fontName size:fontSize];
}

@end
