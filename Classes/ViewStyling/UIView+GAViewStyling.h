//
//  UIView+GAViewStyling.h
//  GAJavaScript
//
//  Created by Andrew Goodale on 6/23/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAScriptEngine;

/**
 * Extension to UIViews for driving visual features via CSS.
 */
@interface UIView (GAViewStyling)

- (NSString *)styleSelector;

- (void)applyStylesWithScriptEngine:(GAScriptEngine *)engine;

- (void)applyComputedStyles:(id)cssDeclaration;

@end

#pragma mark -

@interface UINavigationBar (GAViewStyling)

- (void)applyComputedStyles:(id)cssDeclaration;

@end

#pragma mark -

@interface UILabel (GAViewStyling)

- (void)applyComputedStyles:(id)cssDeclaration;

@end

