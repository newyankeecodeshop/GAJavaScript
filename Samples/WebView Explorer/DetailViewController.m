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
#import "GAScriptObject.h"
#import "GAScriptMethodSignatures.h"
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

- (IBAction)invokeJavaScript:(id)sender
{
    NSString* prompt = @"Hello from Objective-C";
    NSString* js = [NSString stringWithFormat:@"window.prompt('%@')", prompt];
    NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"window prompt: %@", result);
    
    // The importance of escaping data
    //
    prompt = @"This is a javascript prompt";
    js = [NSString stringWithFormat:@"window.proompt('%@')", prompt];
//    js = [NSString stringWithFormat:@"try { %@; } catch (ex) { JSON.stringify(ex); }", js];
    result = [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"window prompt: %@", result);
    
    // Often you need to call toString() manually
    //
    js = [NSString stringWithFormat:@"new Date(%.0f)", [[NSDate date] timeIntervalSince1970] * 1000];
    result = [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"new Date: %@", result);
    
    js = [NSString stringWithFormat:@"new Date(%.0f).toString()", [[NSDate date] timeIntervalSince1970] * 1000];
    result = [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"new Date: %@", result);
    
    
    // Can help with error detection
//    js = [NSString stringWithFormat:@"try { %@; } catch (ex) { ex.toString(); }", js];
}

#pragma mark - UIViewController

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
    
    // Add the methods for DOM Traversal
    [GAScriptMethodSignatures addMethodSignaturesForClass:[DOMTraversal class]];

    NSURL* url = [[NSUserDefaults standardUserDefaults] URLForKey:@"WebView URL"];
    
    if (url)
    {
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.urlField setText:[url absoluteString]];
    }
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
    NSLog(@"DetailView will load %@", [request URL]);
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_urlField isFirstResponder])
        [_urlField resignFirstResponder];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{   
    // Save the URL for future runs
    [[NSUserDefaults standardUserDefaults] setURL:[webView.request URL] forKey:@"WebView URL"];
    
    if (_rootController.document == nil)
    {
        [_rootController setDocument:[webView documentJS]];
        [_rootController setRootNode:[webView documentJS]];
    }
    
    [[webView documentJS] setFunctionForKey:@"ontouchstart" withBlock:^ (NSArray* arguments)
    {
        id touchEvent = [arguments objectAtIndex:0];
        [_scriptEngine callFunction:@"console.log" withObject:@"ontouchstart"];
        
        [_rootController setRootNode:[touchEvent valueForKey:@"target"]];
    }];
    
    // Override the webview console to call us back so we can log to NSLog()
    //
    id console = [[webView windowJS] valueForKey:@"console"];
    
    [console setFunctionForKey:@"log" withBlock:^ (NSArray* arguments)
    {
        if ([arguments count] == 2)
        {
            NSLog(@"WebView: %@ %@", [arguments objectAtIndex:0], [arguments objectAtIndex:1]);
        }
        else
        {
            NSLog(@"WebView: %@", [arguments objectAtIndex:0]);
        }
    }];
}

@end
