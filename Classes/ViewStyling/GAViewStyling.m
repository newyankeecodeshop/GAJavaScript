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

static NSCharacterSet* kSkipSet;
static dispatch_once_t s_onceToken;
static void(^s_initBlock)(void) = ^(void)
{
    kSkipSet = [[NSCharacterSet characterSetWithCharactersInString:@", %"] retain];
};

@implementation UIColor (GAViewStyling)

+ (UIColor *)colorWithCSSColor:(NSString *)cssColor
{    
    dispatch_once(&s_onceToken, s_initBlock);
    
    if (cssColor == nil || [cssColor length] == 0)
        return [UIColor clearColor];
    
    // Look for "rgb[a](". If there's no match, just return a transparent color.
    //
    NSScanner* scanner = [NSScanner scannerWithString:cssColor];
    [scanner setCharactersToBeSkipped:kSkipSet];
    
    if (![scanner scanString:@"rgb(" intoString:NULL] && ![scanner scanString:@"rgba(" intoString:NULL])
        return [UIColor clearColor];

    CGFloat r, g, b, a;
    
    if ([scanner scanFloat:&r])
        r /= 255.f;
    if ([scanner scanFloat:&g])
        g /= 255.f;
    if ([scanner scanFloat:&b])
        b /= 255.f;
    if (![scanner scanFloat:&a])     // Might have been rgba(...)
        a = 1.0f;
        
    // Optimize common colors (black, white, transparent)
    //
    if (r == 1.0f && g == 1.0f && b == 1.0f)
        return [UIColor colorWithWhite:1.0f alpha:a];
    else if (r == 0.0f && g == 0.0f && b == 0.0f)
        return [UIColor colorWithWhite:0.0f alpha:a];
    
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
    NSString* cssFontSize = [cssDeclaration valueForKey:@"font-size"];

    BOOL wantBold = [cssFontWeight isEqualToString:@"bold"];
    BOOL wantItalic = [cssFontStyle isEqualToString:@"italic"];

    // Font size is in pixels, and we must convert to points.
    //
    CGFloat sizeInPoints = [cssFontSize integerValue] / [[UIScreen mainScreen] scale];
    
    NSArray* families = [cssFontFamily componentsSeparatedByString:@", "];
    NSArray* candidateFontNames = nil;
    
    // First, get the family we want...
    //
    for (NSString* family in families)
    {        
        // Handle the mapping of generic family names
        //
        if ([family caseInsensitiveCompare:@"serif"] == NSOrderedSame)
            family = @"Times New Roman";
        else if ([family caseInsensitiveCompare:@"sans-serif"] == NSOrderedSame)
            family = @"Helvetica";
        
        candidateFontNames = [UIFont fontNamesForFamilyName:family];
        
        if ([candidateFontNames count] > 0)
            break;
    }
    
    if ([candidateFontNames count] == 0)
    {
        return [UIFont systemFontOfSize:sizeInPoints];
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
        
    return [UIFont fontWithName:fontName size:sizeInPoints];
}

@end

#pragma mark -

@implementation UIImage (GAViewStyling)

+ (UIImage *)imageWithCSSURL:(NSString *)cssUrl
{
    // Make a NSURL by using everything inside the "url(...)" string
    //
    NSRange urlRange = NSMakeRange(4, [cssUrl length] - 5);
    NSURL* theUrl = [NSURL URLWithString:[cssUrl substringWithRange:urlRange]];
    
    if ([[theUrl scheme] isEqualToString:NSURLFileScheme])
    {
        GADebugStr(@"Loading image named '%@'", [theUrl lastPathComponent]);
        
        return [UIImage imageNamed:[theUrl lastPathComponent]];
    }
    else if ([[theUrl scheme] isEqualToString:@"data"])
    {
        NSError* myErr = nil;
        NSData* imgData = [NSData dataWithContentsOfURL:theUrl options:0 error:&myErr];
        
        if (myErr != nil)
        {
            NSLog(@"Could not make NSData from data URL: %@", myErr);
            return nil;
        }
        
        return [UIImage imageWithData:imgData];
    }
    
    NSAssert(YES, @"Unsupported URL scheme for UIImage (GAViewStyling): %@", [theUrl scheme]);
    return nil;
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
    dispatch_once(&s_onceToken, s_initBlock);

    if (cssGradient == nil || [cssGradient length] == 0)
        return;
    
    NSScanner* scanner = [NSScanner scannerWithString:cssGradient];
    [scanner setCharactersToBeSkipped:kSkipSet];

    if (![scanner scanString:@"-webkit-gradient(linear" intoString:NULL])
        return;
    
    // The start and end points come out of WebKit as percentages
    //
    CGPoint start = { .5f, 0.0f }, end = { .5f, 1.0f };
    
    if ([scanner scanFloat:&start.x])
        start.x /= 100.0f;
    if ([scanner scanFloat:&start.y])
        start.y /= 100.0f;
    if ([scanner scanFloat:&end.x])
        end.x /= 100.0f;
    if ([scanner scanFloat:&end.y])
        end.y /= 100.0f;
    
    [self setStartPoint:start];
    [self setEndPoint:end];
    
    NSMutableArray* colors = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray* locations = [[NSMutableArray alloc] initWithCapacity:4];
    
    while (![scanner isAtEnd])
    {
        CGFloat location = 0.0f;
        NSString* colorStop = nil;
        
        if ([scanner scanString:@"from(" intoString:NULL])
        {
            location = 0.0f;
        }
        else if ([scanner scanString:@"to(" intoString:NULL])
        {
            location = 1.0f;
        }
        else if ([scanner scanString:@"color-stop(" intoString:NULL])
        {
            [scanner scanFloat:&location];
        }
        else
        {
            break;
        }

        if (![scanner scanUpToString:@"))" intoString:&colorStop])
            break;
        
        // Keep the color and location arrays the same length
        //
        UIColor* color = [UIColor colorWithCSSColor:colorStop];
        [colors addObject:(id)[color CGColor]];
        [locations addObject:[NSNumber numberWithFloat:location]];
        
        [scanner scanString:@"))" intoString:NULL];
    }
    
    [self setColors:colors];
    [self setLocations:locations];
    [colors release];
    [locations release];
}

@end

