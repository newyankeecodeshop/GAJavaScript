//
//  TNSObjectCategories.m
//  GAJavaScript
//
//  Created by Andrew Goodale on 9/1/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "TObjectCategories.h"
#import "NSObject+GAJavaScript.h"

@implementation TObjectCategories

- (void)testStringEncoding
{
    NSString* testData, *encData;
    
    testData = @"A simple string";
    encData = [testData stringForJavaScript];
    GHAssertTrue([encData hasPrefix:@"'A"] && [encData hasSuffix:@"g'"], @"Did not get proper string back");
    GHAssertTrue([[[encData class] description] rangeOfString:@"NSCFString"].location != NSNotFound, 
                 @"Converted string should not be mutable");
    
    testData = @"quote ', double \", backslash \\";
    encData = [testData stringForJavaScript];
    GHAssertTrue([encData isEqualToString:@"'quote \\', double \\\", backslash \\\\'"], @"Back encoding %@", encData);
    
    testData = @"\b\t\n\v\f\r";
    encData = [testData stringForJavaScript];
    GHAssertTrue([encData isEqualToString:@"'\\u0008\\u0009\\u000A\\u000B\\u000C\\u000D'"], @"Back encoding %@", encData);

    testData = @"control , greek beta \u03b2";
    encData = [testData stringForJavaScript];
    GHAssertTrue([encData isEqualToString:@"'control , greek beta \u03b2'"], @"Back encoding %@", encData);
}

- (void)testObjectEncoding
{
    TestObject* test = [[TestObject alloc] init];
    test.stringProp = @"Hello World";
    test.intProp = 1024;
    test.dateProp = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 24];
    
    NSString* jsText = [test stringForJavaScript];
    GHAssertTrue([jsText rangeOfString:@" dateProp:new Date("].location != NSNotFound, @"Date property not serialized");
    GHAssertTrue([jsText rangeOfString:@" intProp:1024"].location != NSNotFound, @"Int property not serialized");
    GHAssertTrue([jsText rangeOfString:@" stringProp:'Hello World'"].location != NSNotFound, @"String property not serialized");
    
    [test release];
}

@end

@implementation TestObject

@synthesize stringProp, intProp, dateProp;

- (void)dealloc
{
    [stringProp release];
    [dateProp release];
    
    [super dealloc];
}

@end