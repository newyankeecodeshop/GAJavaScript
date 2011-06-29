//
//  UIView+GAViewStyling.h
//  GAJavaScript
//
//  Created by Andrew Goodale on 6/23/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (GAViewStyling)

- (NSString *)styleSelector;

- (void)applyStylesFromWebView:(UIWebView *)webView;

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

