/*
     File: TransitionViewController.m 
 Abstract: The view controller for showing transitions with UIView. 
  Version: 2.9 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "TransitionViewController.h"
#import "Constants.h"

#define kImageHeight		200.0
#define kImageWidth			250.0
#define kTransitionDuration	0.75
#define kTopPlacement		80.0	// y coord for the images

#pragma mark -

@implementation TransitionsViewController

@synthesize containerView, mainView, flipToView;

- (void)dealloc
{
	[mainView release];
	[flipToView release];
	[containerView release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"TransitionsTitle", @"");

	// create the container view which we will use for transition animation (centered horizontally)
	CGRect frame = CGRectMake(round((self.view.bounds.size.width - kImageWidth) / 2.0),
														kTopPlacement, kImageWidth, kImageHeight);
	self.containerView = [[[UIView alloc] initWithFrame:frame] autorelease];
	[self.view addSubview:self.containerView];
	
	// The container view can represent the images for accessibility.
	[self.containerView setIsAccessibilityElement:YES];
	[self.containerView setAccessibilityLabel:NSLocalizedString(@"ImagesTitle", @"")];
	
	// create the initial image view
	frame = CGRectMake(0.0, 0.0, kImageWidth, kImageHeight);
	self.mainView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
	self.mainView.image = [UIImage imageNamed:@"scene1.jpg"];
	[self.containerView addSubview:self.mainView];
	
	// create the alternate image view (to transition between)
	CGRect imageFrame = CGRectMake(0.0, 0.0, kImageWidth, kImageHeight);
	self.flipToView = [[[UIImageView alloc] initWithFrame:imageFrame] autorelease];
	self.flipToView.image = [UIImage imageNamed:@"scene2.jpg"];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.containerView = nil;
	self.flipToView = nil;
	self.mainView = nil;
}

- (IBAction)curlAction:(id)sender
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	
	[UIView setAnimationTransition:([self.mainView superview] ?
									UIViewAnimationTransitionCurlUp : UIViewAnimationTransitionCurlDown)
						   forView:self.containerView cache:YES];
	if ([self.flipToView superview])
	{
		[self.flipToView removeFromSuperview];
		[self.containerView addSubview:self.mainView];
	}
	else
	{
		[self.mainView removeFromSuperview];
		[self.containerView addSubview:self.flipToView];
	}
	
	[UIView commitAnimations];
}

- (IBAction)flipAction:(id)sender
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
		
	[UIView setAnimationTransition:([self.mainView superview] ?
										UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
										forView:self.containerView cache:YES];
	if ([flipToView superview])
	{
		[self.flipToView removeFromSuperview];
		[self.containerView addSubview:mainView];
	}
	else
	{
		[self.mainView removeFromSuperview];
		[self.containerView addSubview:flipToView];
	}
	
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{	
	// restore the nav bar and status bar color to default
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{	
	// for aesthetic reasons (the background is black), make the nav bar black for this particular page
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	// match the status bar with the nav bar
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}

@end

