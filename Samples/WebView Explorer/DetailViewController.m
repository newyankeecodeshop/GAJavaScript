//
//  DetailViewController.m
//  WebView Explorer
//
//  Created by Andrew Goodale on 6/5/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "GAScriptEngine.h"
#import "GAScriptBlockObject.h"
#import "UIWebView+GAJavaScript.h"

@interface DetailViewController ()

@property (nonatomic, retain) UIPopoverController *popoverController;

@end

#pragma mark -

@implementation DetailViewController

@synthesize toolbar=_toolbar;
@synthesize urlField=_urlField;
@synthesize webView=_webView;
@synthesize scriptEngine = _scriptEngine;
@synthesize rootController = _rootController;
@synthesize popoverController=_myPopoverController;

#pragma mark - Managing the detail item

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

#pragma mark - Split view support

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"DOM Tree";
    
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scriptEngine = [[GAScriptEngine alloc] initWithWebView:_webView];
}


- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// 
    self.urlField = nil;
    self.webView = nil;
	self.popoverController = nil;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_myPopoverController release];
    [_toolbar release];
    [_urlField release];
    [_webView release];

    [super dealloc];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSURL* url = [NSURL URLWithString:[textField text]];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    return YES;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
                                                 navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_urlField isFirstResponder])
        [_urlField resignFirstResponder];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{   
    NSString* js = [NSString stringWithFormat:@"window.alert('Hello from Objective-C')"];
    NSString* result = [webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"UIWebView: %@", result);
    
    NSDate* date = [NSDate date];
    js = [NSString stringWithFormat:@"new Date(%.0f)", [date timeIntervalSince1970] * 1000];
    result = [webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"UIWebView: %@", result);

    js = [NSString stringWithFormat:@"new Date(%.0f).toString()", [date timeIntervalSince1970] * 1000];
    result = [webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"UIWebView: %@", result);
    
    js = @"var arrayValue = [1000, 2000, 3000, 'String with a comma,', 5000]";
    result = [webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"UIWebView: %@", result);

    js = @"arrayValue.toString()";
    result = [webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"UIWebView: %@", result);
}

@end
