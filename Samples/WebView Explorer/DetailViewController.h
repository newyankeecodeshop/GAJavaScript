//
//  DetailViewController.h
//  WebView Explorer
//
//  Created by Andrew Goodale on 6/5/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAScriptEngine;
@class RootViewController;

@interface DetailViewController : UIViewController 
    <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITextFieldDelegate, UIWebViewDelegate> 
{    
    UITextField*    _urlField;
    UIWebView*      _webView;

    GAScriptEngine*     _scriptEngine;
    RootViewController* _rootController;
}

@property (nonatomic, retain) IBOutlet UIToolbar *  toolbar;

@property (nonatomic, retain) IBOutlet UITextField* urlField;
@property (nonatomic, retain) IBOutlet UIWebView*   webView;

@property (nonatomic, retain) GAScriptEngine*   scriptEngine;
@property (nonatomic, assign) RootViewController *  rootController;

- (IBAction)invokeJavaScript:(id)sender;

@end
