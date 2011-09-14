/*
     File: SegmentViewController.m 
 Abstract: The view controller for hosting the UISegmentedControl features of this sample. 
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

#import "SegmentViewController.h"
#import "Constants.h"

#define kSegmentedControlHeight 40.0
#define kLabelHeight			20.0

@implementation SegmentViewController

+ (UILabel *)labelWithFrame:(CGRect)frame title:(NSString *)title
{
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    
	label.textAlignment = UITextAlignmentLeft;
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
    label.backgroundColor = [UIColor clearColor];
	
    return label;
}

- (void)segmentAction:(id)sender
{
	//NSLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
}

- (void)createControls
{
	NSArray *segmentTextContent = [NSArray arrayWithObjects: @"Check", @"Search", @"Tools", nil];
	
	// label
	CGFloat yPlacement = kTopMargin;
	CGRect frame = CGRectMake(kLeftMargin, yPlacement, self.view.bounds.size.width - (kRightMargin * 2.0), kLabelHeight);
	[self.view addSubview:[SegmentViewController labelWithFrame:frame title:@"UISegmentedControl:"]];
	
#pragma mark -
#pragma mark UISegmentedControl
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
												[NSArray arrayWithObjects:
													[UIImage imageNamed:@"segment_check.png"],
													[UIImage imageNamed:@"segment_search.png"],
													[UIImage imageNamed:@"segment_tools.png"],
													nil]];
	yPlacement += kTweenMargin + kLabelHeight;
	frame = CGRectMake(	kLeftMargin,
						yPlacement,
						self.view.bounds.size.width - (kRightMargin * 2.0),
						kSegmentedControlHeight);
	segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedControl.selectedSegmentIndex = 1;	
	[self.view addSubview:segmentedControl];
	[segmentedControl release];
	
	// Add the appropriate accessibility label to each image.
	[[segmentedControl imageForSegmentAtIndex:0] setAccessibilityLabel:NSLocalizedString(@"CheckMarkIcon", @"")];
	[[segmentedControl imageForSegmentAtIndex:1] setAccessibilityLabel:NSLocalizedString(@"SearchIcon", @"")];
	[[segmentedControl imageForSegmentAtIndex:2] setAccessibilityLabel:NSLocalizedString(@"ToolsIcon", @"")];

	// label
	yPlacement += (kTweenMargin * 2.0) + kSegmentedControlHeight;
	frame = CGRectMake(	kLeftMargin,
						yPlacement,
						self.view.bounds.size.width - (kRightMargin * 2.0),
						kLabelHeight);
	[self.view addSubview:[SegmentViewController labelWithFrame:frame title:@"UISegmentControlStyleBordered:"]];
	
#pragma mark -
#pragma mark UISegmentControlStyleBordered
	segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	yPlacement += kTweenMargin + kLabelHeight;
	frame = CGRectMake(	kLeftMargin,
						yPlacement,
						self.view.bounds.size.width - (kRightMargin * 2.0),
						kSegmentedControlHeight);
	segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
	segmentedControl.selectedSegmentIndex = 1;
	
	[self.view addSubview:segmentedControl];
	[segmentedControl release];

	// label
	yPlacement += (kTweenMargin * 2.0) + kSegmentedControlHeight;
	frame = CGRectMake(	kLeftMargin,
					   yPlacement,
					   self.view.bounds.size.width - (kRightMargin * 2.0),
					   kLabelHeight);
	[self.view addSubview:[SegmentViewController labelWithFrame:frame title:@"UISegmentControlStyleBar:"]];
	
#pragma mark -
#pragma mark UISegmentControlStyleBar
	yPlacement += kTweenMargin + kLabelHeight;
	segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	frame = CGRectMake(	kLeftMargin,
					   yPlacement,
					   self.view.bounds.size.width - (kRightMargin * 2.0),
					   kSegmentedControlHeight);
	segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex = 1;
	
	[self.view addSubview:segmentedControl];
	[segmentedControl release];
	
	// label
	yPlacement += (kTweenMargin * 2.0) + kSegmentedControlHeight;
	frame = CGRectMake(	kLeftMargin,
						yPlacement,
						self.view.bounds.size.width,
						kLabelHeight);
	[self.view addSubview:[SegmentViewController labelWithFrame:frame title:@"UISegmentControlStyleBar: (tinted)"]];
		
#pragma mark -
#pragma mark UISegmentedControl (red-tinted)
	segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	yPlacement += kTweenMargin + kLabelHeight;
	frame = CGRectMake(	kLeftMargin,
						yPlacement,
						self.view.bounds.size.width - (kRightMargin * 2.0),
						kSegmentedControlHeight);
	segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;	
	segmentedControl.tintColor = [UIColor colorWithRed:0.70 green:0.171 blue:0.1 alpha:1.0];
	segmentedControl.selectedSegmentIndex = 1;
	
	[self.view addSubview:segmentedControl];
	[segmentedControl release];
#pragma mark -
}

- (void)viewDidLoad
{	
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"SegmentTitle", @"");
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];	// use the table view background color
	
	[self createControls];	// create the showcase of controls
}

@end

