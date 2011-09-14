/*
     File: ToolbarViewController.m 
 Abstract: The view controller for hosting the UIToolbar and UIBarButtonItem features of this sample. 
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

#import "ToolbarViewController.h"
#import "ThemeAppDelegate.h"
#import "Constants.h"

@implementation ToolbarViewController

@synthesize barStyleSegControl, tintSwitch, buttonItemStyleSegControl, systemButtonPicker;
@synthesize toolbar, pickerViewArray;

- (void)dealloc
{	
    [toolbar release];
	[pickerViewArray release];
	
	[barStyleSegControl release];
	[tintSwitch release];
	[buttonItemStyleSegControl release];
	[systemButtonPicker release];
	
	[super dealloc];
}

// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
								   screenRect.size.height - 84.0 - size.height,
								   size.width,
								   size.height);
	return pickerRect;
}

- (void)action:(id)sender
{
	//NSLog(@"UIBarButtonItem clicked");
}

- (void)createToolbarItems
{	
	// match each of the toolbar item's style match the selection in the "UIBarButtonItemStyle" segmented control
	UIBarButtonItemStyle style = [self.buttonItemStyleSegControl selectedSegmentIndex];

	// create the system-defined "OK or Done" button
    UIBarButtonItem *systemItem = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:currentSystemItem
									target:self action:@selector(action:)];
	systemItem.style = style;
	
	// flex item used to separate the left groups items and right grouped items
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			   target:nil
																			   action:nil];
	
	// create a special tab bar item with a custom image and title
	UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"segment_tools.png"]
																  style:style
																 target:self
																 action:@selector(action:)];
	// Set the accessibility label for an image bar item.
	[infoItem setAccessibilityLabel:NSLocalizedString(@"ToolsIcon", @"")];
	
	// create a bordered style button with custom title
	UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithTitle:@"Item"
																	style:style	// note you can use "UIBarButtonItemStyleDone" to make it blue
																   target:self
																   action:@selector(action:)];
	
	NSArray *items = [NSArray arrayWithObjects: systemItem, flexItem, customItem, infoItem, nil];
	[self.toolbar setItems:items animated:NO];
	
	[systemItem release];
	[flexItem release];
	[infoItem release];
	[customItem release];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// release and set to nil
	self.pickerViewArray = nil;
	self.toolbar = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// this list appears in the UIPickerView to pick the system's UIBarButtonItem
	self.pickerViewArray = [NSArray arrayWithObjects:
									@"Done",
									@"Cancel",
									@"Edit",  
									@"Save",  
									@"Add",
									@"FlexibleSpace",
									@"FixedSpace",
									@"Compose",
									@"Reply",
									@"Action",
									@"Organize",
									@"Bookmarks",
									@"Search",
									@"Refresh",
									@"Stop",
									@"Camera",
									@"Trash",
									@"Play",
									@"Pause",
									@"Rewind",
									@"FastForward",
									// new in 3.0 SDK:
									@"Undo",
									@"Redo",
									// new in 4.0 SDK:
									@"PageCurl",
								nil];
	
	self.title = NSLocalizedString(@"ToolbarTitle", @"");
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];	// use the table view background color
	
	// create the UIToolbar at the bottom of the view controller
	//
	toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleDefault;
	
	// size up the toolbar and set its frame
	[toolbar sizeToFit];
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	
	[self.view addSubview:toolbar];
	
	currentSystemItem = UIBarButtonSystemItemDone;
	[self createToolbarItems];
	
	// Set the accessibility label for the tint switch so that its context can be determined.
	[self.tintSwitch setAccessibilityLabel:NSLocalizedString(@"TintSwitch", @"")];
}

- (IBAction)toggleStyle:(id)sender
{
	UIBarButtonItemStyle style = UIBarButtonItemStylePlain;
	
	switch ([sender selectedSegmentIndex])
	{
		case 0:	// UIBarButtonItemStylePlain
		{
			style = UIBarButtonItemStylePlain;
			break;
		}
		case 1: // UIBarButtonItemStyleBordered
		{	
			style = UIBarButtonItemStyleBordered;
			break;
		}
		case 2:	// UIBarButtonItemStyleDone
		{
			style = UIBarButtonItemStyleDone;
			break;
		}
	}

	NSArray *toolbarItems = toolbar.items;
	UIBarButtonItem *item;
	for (item in toolbarItems)
	{
		item.style = style;
	}
}

- (IBAction)toggleBarStyle:(id)sender
{
	switch ([sender selectedSegmentIndex])
	{
		case 0:
			toolbar.barStyle = UIBarStyleDefault;
			break;
		case 1:
			toolbar.barStyle = UIBarStyleBlackOpaque;
			break;
		case 2:
			toolbar.barStyle = UIBarStyleBlackTranslucent;
			break;
	}
}

- (IBAction)toggleTintColor:(id)sender
{
	UISwitch *switchCtl = (UISwitch *)sender;
	if (switchCtl.on)
	{
		toolbar.tintColor = [UIColor redColor];
		barStyleSegControl.enabled = NO;
		barStyleSegControl.alpha = 0.50;
	}
	else
	{
		toolbar.tintColor = nil; // no color
		barStyleSegControl.enabled = YES;
		barStyleSegControl.alpha = 1.0;
	}
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// change the left most bar item to what's in the picker
	currentSystemItem = [pickerView selectedRowInComponent:0];
	[self createToolbarItems];	// this will re-create all the items
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [pickerViewArray objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 240.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [pickerViewArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

@end


