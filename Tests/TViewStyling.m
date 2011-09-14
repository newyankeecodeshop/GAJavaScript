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

#import "TViewStyling.h"
#import <QuartzCore/QuartzCore.h>
#import "GAViewStyling.h"

@implementation TViewStyling

- (void)testColorFromCSSDeclaration
{
    UIColor* color = [UIColor colorWithCSSColor:@"rgb(128, 128, 128)"];
    
    NSString* testColor = [color description];
    GHAssertTrue([testColor rangeOfString:@"0.501961 0.501961 0.501961"].location != NSNotFound, @"Color not converted");
    
    color = [UIColor colorWithCSSColor:@"rgb(0, 0, 0)"];
    
    testColor = [color description];
    GHAssertTrue([testColor rangeOfString:@"UIDeviceWhiteColorSpace 0"].location != NSNotFound, @"Color not converted");

    color = [UIColor colorWithCSSColor:@"rgba(0, 0, 0, 0)"];
    
    testColor = [color description];
    GHAssertTrue([testColor rangeOfString:@"UIDeviceWhiteColorSpace 0 0"].location != NSNotFound, @"Color not converted");

    color = [UIColor colorWithCSSColor:@"rgb(240, 120, 0) 0px 1px"];     // Like a text-shadow decl
    
    testColor = [color description];
    GHAssertTrue([testColor rangeOfString:@"0.941176 0.470588 0"].location != NSNotFound, @"Color not converted");

    // Error handling...
    //
    color = [UIColor colorWithCSSColor:@"1, 2, 3, 4, 5"];
    
    testColor = [color description];
    GHAssertTrue([testColor rangeOfString:@"UIDeviceWhiteColorSpace 0 0"].location != NSNotFound, @"Color not converted");

    color = [UIColor colorWithCSSColor:nil];
    
    testColor = [color description];
    GHAssertTrue([testColor rangeOfString:@"UIDeviceWhiteColorSpace 0 0"].location != NSNotFound, @"Color not converted");
}

- (void)testFontFromCSSDeclaration
{
    MockCSSDeclaration* decl = [[MockCSSDeclaration alloc] init];
    decl.fontFamily = @"Verdana, sans-serif";
    decl.fontSize = @"24px";
    decl.fontStyle = @"normal";
    decl.fontWeight = @"normal";
    
    UIFont* font = [UIFont fontWithCSSDeclaration:decl];
    GHAssertTrue([font.familyName isEqualToString:@"Verdana"], @"Wrong font family");

    // Test that we can get the Bold font
    //
    decl.fontWeight = @"bold";

    font = [UIFont fontWithCSSDeclaration:decl];
    GHAssertTrue([font.familyName isEqualToString:@"Verdana"], @"Wrong font family");
    GHAssertTrue([font.fontName isEqualToString:@"Verdana-Bold"], @"Wrong font name");
    
    // Test that we skip over fonts that aren't installed
    //
    decl.fontFamily = @"MyFakeFont, Verdana, sans-serif";
    
    font = [UIFont fontWithCSSDeclaration:decl];
    GHAssertTrue([font.familyName isEqualToString:@"Verdana"], @"Wrong font family");
    GHAssertTrue([font.fontName isEqualToString:@"Verdana-Bold"], @"Wrong font name");

    // Test that we can get the Italic font
    //
    decl.fontWeight = @"normal";
    decl.fontStyle = @"italic";
    
    font = [UIFont fontWithCSSDeclaration:decl];
    GHAssertTrue([font.familyName isEqualToString:@"Verdana"], @"Wrong font family");
    GHAssertTrue([font.fontName isEqualToString:@"Verdana-Italic"], @"Wrong font name");

    // Test that we can get the BoldItalic font
    //
    decl.fontWeight = @"bold";
    decl.fontStyle = @"italic";
    
    font = [UIFont fontWithCSSDeclaration:decl];
    GHAssertTrue([font.familyName isEqualToString:@"Verdana"], @"Wrong font family");
    GHAssertTrue([font.fontName isEqualToString:@"Verdana-BoldItalic"], @"Wrong font name");

    // Test that we skip over fonts that aren't installed
    //
    decl.fontFamily = @"MyFakeFont, Verdannnnnna, sans-serif";
    decl.fontStyle = @"normal";
    
    font = [UIFont fontWithCSSDeclaration:decl];
    GHAssertTrue([font.familyName isEqualToString:@"Helvetica"], @"Wrong font family");
    GHAssertTrue([font.fontName isEqualToString:@"Helvetica-Bold"], @"Wrong font name");
    
    [decl release];
}

- (void)testSizeFromCSSLengths
{
    NSString* lengths = @"100px 200px";
    CGSize size = GASizeFromCSSLengths(lengths);
    GHAssertTrue(size.width == 100 && size.height == 200, @"Wrong width or height!");

    lengths = @"10.5px 20.75px";
    size = GASizeFromCSSLengths(lengths);
    GHAssertTrue(size.width == 10.5 && size.height == 20.75, @"Float values not handled!");

    lengths = @"100 200";
    size = GASizeFromCSSLengths(lengths);
    GHAssertTrue(size.width == 0 && size.height == 0, @"Bad string not handled!");
}

- (void)testGradientLayer
{
    CAGradientLayer* layer = [CAGradientLayer layer];
    
    NSString* cssGradient = @"-webkit-gradient(linear, 100% 0%, 0% 100%, color-stop(0.19, rgb(128, 22, 48)), color-stop(0.6, rgb(224, 36, 74)), color-stop(0.8, rgb(235, 52, 88)))";
    [layer setValuesWithCSSGradient:cssGradient];
    
    GHAssertNotNil(layer, @"Bad layer");
    GHAssertTrue([layer.colors count] == 3, @"Wrong number of colors");
    
    CGColorRef color1 = (CGColorRef)[layer.colors objectAtIndex:0];
    const CGFloat* pColors = CGColorGetComponents(color1);
    GHAssertTrue(pColors[0] == 128/255.f && pColors[1] == 22/255.f && pColors[2] == 48/255.f, @"Bad colors");

    CGColorRef color2 = (CGColorRef)[layer.colors objectAtIndex:1];
    pColors = CGColorGetComponents(color2);
    GHAssertTrue(pColors[0] == 224/255.f && pColors[1] == 36/255.f && pColors[2] == 74/255.f, @"Bad colors");

    CGColorRef color3 = (CGColorRef)[layer.colors objectAtIndex:2];
    pColors = CGColorGetComponents(color3);
    GHAssertTrue(pColors[0] == 235/255.f && pColors[1] == 52/255.f && pColors[2] == 88/255.f, @"Bad colors");
    
    NSNumber* loc1 = [layer.locations objectAtIndex:0];
    GHAssertTrue([loc1 floatValue] == 0.19f, @"Location wrong");

    NSNumber* loc2 = [layer.locations objectAtIndex:1];
    GHAssertTrue([loc2 floatValue] == 0.6f, @"Location wrong");

    NSNumber* loc3 = [layer.locations objectAtIndex:2];
    GHAssertTrue([loc3 floatValue] == 0.8f, @"Location wrong");
}

@end

#pragma mark -

@implementation MockCSSDeclaration

@synthesize fontFamily = _fontFamily, fontSize = _fontSize, fontStyle = _fontStyle, fontWeight = _fontWeight;

// Implement support for the real CSS property names, which would be supported by GAScriptObject
//
- (id)valueForKey:(NSString *)key
{
    if ([key isEqualToString:@"font-family"])
        return self.fontFamily;
    
    if ([key isEqualToString:@"font-size"])
        return self.fontSize;

    if ([key isEqualToString:@"font-style"])
        return self.fontStyle;

    if ([key isEqualToString:@"font-weight"])
        return self.fontWeight;

    return [super valueForKey:key];
}

@end