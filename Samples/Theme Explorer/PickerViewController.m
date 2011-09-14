/*
     File: PickerViewController.m 
 Abstract: The view controller for hosting the UIPickerView of this sample. 
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

#import "PickerViewController.h"
#import "CustomView.h"
#import "Constants.h"

@implementation PickerViewController

@synthesize buttonBarSegmentedControl, pickerStyleSegmentedControl, segmentLabel, currentPicker;
@synthesize myPickerView, datePickerView, pickerViewArray, label, customPickerView, customPickerDataSource;

// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
									screenRect.size.height - 42.0 - size.height,
									size.width,
									size.height);
	return pickerRect;
}

#pragma mark -
#pragma mark UIPickerView

- (void)createPicker
{
	self.pickerViewArray = [NSArray arrayWithObjects:
								@"John Appleseed", @"Chris Armstrong", @"Serena Auroux",
								@"Susan Bean", @"Luis Becerra", @"Kate Bell", @"Alain Briere",
							nil];
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	myPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	CGSize pickerSize = [myPickerView sizeThatFits:CGSizeZero];
	myPickerView.frame = [self pickerFrameWithSize:pickerSize];

	myPickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	// this view controller is the data source and delegate
	myPickerView.delegate = self;
	myPickerView.dataSource = self;
	
	// add this picker to our view controller, initially hidden
	myPickerView.hidden = YES;
	[self.view addSubview:myPickerView];
}


#pragma mark -
#pragma mark UIPickerView - Date/Time

- (void)createDatePicker
{
	datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	datePickerView.datePickerMode = UIDatePickerModeDate;
	
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	CGSize pickerSize = [myPickerView sizeThatFits:CGSizeZero];
	datePickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	// add this picker to our view controller, initially hidden
	datePickerView.hidden = YES;
	[self.view addSubview:datePickerView];
}


#pragma mark -
#pragma mark UIPickerView - Custom Picker

- (void)createCustomPicker
{
	customPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	customPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	
	// setup the data source and delegate for this picker
	customPickerDataSource = [[CustomPickerDataSource alloc] init];
	customPickerView.dataSource = customPickerDataSource;
	customPickerView.delegate = customPickerDataSource;
	
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	CGSize pickerSize = [myPickerView sizeThatFits:CGSizeZero];
	customPickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	customPickerView.showsSelectionIndicator = YES;
	
	// add this picker to our view controller, initially hidden
	customPickerView.hidden = YES;
	[self.view addSubview:customPickerView];
}


#pragma mark -
#pragma mark Actions

- (void)showPicker:(UIView *)picker
{
	// hide the current picker and show the new one
	if (currentPicker)
	{
		currentPicker.hidden = YES;
		label.text = @"";
	}
	picker.hidden = NO;
	
	currentPicker = picker;	// remember the current picker so we can remove it later when another one is chosen
}

- (IBAction)togglePickerStyle:(id)sender
{
	UISegmentedControl *segControl = sender;
	switch (segControl.selectedSegmentIndex)
	{
		case 0:	// Time
		{
			datePickerView.datePickerMode = UIDatePickerModeTime;
			segmentLabel.text = @"UIDatePickerModeTime";
			break;
		}
		case 1: // Date
		{	
			datePickerView.datePickerMode = UIDatePickerModeDate;
			segmentLabel.text = @"UIDatePickerModeDate";
			break;
		}
		case 2:	// Date & Time
		{
			datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
			segmentLabel.text = @"UIDatePickerModeDateAndTime";
			break;
		}
		case 3:	// Counter
		{
			datePickerView.datePickerMode = UIDatePickerModeCountDownTimer;
			segmentLabel.text = @"UIDatePickerModeCountDownTimer";
			break;
		}
	}
	
	// in case we previously chose the Counter style picker, make sure
	// the current date is restored
	NSDate *today = [NSDate date];
	datePickerView.date = today;
}

- (IBAction)togglePickers:(id)sender
{
	UISegmentedControl *segControl = sender;
	switch (segControl.selectedSegmentIndex)
	{
		case 0:	// UIPickerView
		{
			pickerStyleSegmentedControl.hidden = YES;
			segmentLabel.hidden = YES;
			[self showPicker:myPickerView];
			break;
		}
		case 1: // UIDatePicker
		{	
			// start by showing the time picker
			
			// initially set the picker style to "date" format
			pickerStyleSegmentedControl.selectedSegmentIndex = 1;
			datePickerView.datePickerMode = UIDatePickerModeDate;
			
			pickerStyleSegmentedControl.hidden = NO;
			segmentLabel.hidden = NO;
			[self showPicker:datePickerView];
			break;
		}
			
		case 2:	// Custom
		{
			pickerStyleSegmentedControl.hidden = YES;
			segmentLabel.hidden = YES;
			[self showPicker:customPickerView];
			break;
		}
	}
}


#pragma mark -
#pragma mark View Controller

- (void)viewDidLoad
{		
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"PickerTitle", @"");
	
	[self createPicker];	
	[self createDatePicker];
	[self createCustomPicker];
	
	// tint the bottom toolbar's segmented control with dark grey
	buttonBarSegmentedControl.tintColor = [UIColor darkGrayColor];
	
	// tint the date picker style segmented control with dark grey
	pickerStyleSegmentedControl.tintColor = [UIColor darkGrayColor];
	
	// label for picker selection output, place it right above the picker
	CGRect labelFrame = CGRectMake(	kLeftMargin,
									myPickerView.frame.origin.y - 12.0,
									self.view.bounds.size.width - (kRightMargin * 2.0),
									14.0);
	self.label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
    self.label.font = [UIFont systemFontOfSize:12.0];
	self.label.textAlignment = UITextAlignmentCenter;
	self.label.textColor = [UIColor whiteColor];
	self.label.backgroundColor = [UIColor clearColor];
	self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[self.view addSubview:self.label];
	
	// start by showing the normal picker in date mode
	buttonBarSegmentedControl.selectedSegmentIndex = 0;
	datePickerView.datePickerMode = UIDatePickerModeDate;
}

- (void)dealloc
{
	[pickerViewArray release];
	[myPickerView release];
	[datePickerView release];
	[label release];
	
	[customPickerDataSource release];
	[customPickerView release];
	
	[pickerStyleSegmentedControl release];
	[segmentLabel release];
	
	[buttonBarSegmentedControl release];
	
	[super dealloc];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// release and set out IBOutlets to nil
	self.buttonBarSegmentedControl = nil;
	self.pickerStyleSegmentedControl = nil;
	self.segmentLabel = nil;
	
	// release all the other objects
	self.myPickerView = nil;
	self.pickerViewArray = nil;
	
	self.datePickerView = nil;
	
	self.label = nil;
	
	self.customPickerView = nil;
	self.customPickerDataSource = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == myPickerView)	// don't show selection for the custom picker
	{
		// report the selection to the UI label
		label.text = [NSString stringWithFormat:@"%@ - %d",
						[pickerViewArray objectAtIndex:[pickerView selectedRowInComponent:0]],
						[pickerView selectedRowInComponent:1]];
	}
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	
	// note: custom picker doesn't care about titles, it uses custom views
	if (pickerView == myPickerView)
	{
		if (component == 0)
		{
			returnStr = [pickerViewArray objectAtIndex:row];
		}
		else
		{
			returnStr = [[NSNumber numberWithInt:row] stringValue];
		}
	}
	
	return returnStr;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 0.0;

	if (component == 0)
		componentWidth = 240.0;	// first column size is wider to hold names
	else
		componentWidth = 40.0;	// second column is narrower to show numbers

	return componentWidth;
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
	return 2;
}


#pragma mark -
#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{
	currentPicker.hidden = YES;
	
	// restore the nav bar and status bar color to default
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[self togglePickers:buttonBarSegmentedControl];	// make sure the last picker is still showing
	
	// for aesthetic reasons (the background is black), make the nav bar black for this particular page
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	// match the status bar with the nav bar
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}

@end

