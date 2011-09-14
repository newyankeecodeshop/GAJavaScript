/*
     File: CustomPickerDataSource.m 
 Abstract: The data source for the Custom Picker that displays text and images. 
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

#import "CustomPickerDataSource.h"
#import "CustomView.h"

@implementation CustomPickerDataSource

@synthesize customPickerArray;

- (id)init
{
	// use predetermined frame size
	self = [super init];
	if (self)
	{
		// create the data source for this custom picker
		NSMutableArray *viewArray = [[NSMutableArray alloc] init];

		CustomView *earlyMorningView = [[CustomView alloc] initWithFrame:CGRectZero];
		earlyMorningView.title = @"Early Morning";
		earlyMorningView.image = [UIImage imageNamed:@"12-6AM.png"];
		[viewArray addObject:earlyMorningView];
		[earlyMorningView release];

		CustomView *lateMorningView = [[CustomView alloc] initWithFrame:CGRectZero];
		lateMorningView.title = @"Late Morning";
		lateMorningView.image = [UIImage imageNamed:@"6-12AM.png"];
		[viewArray addObject:lateMorningView];
		[lateMorningView release];

		CustomView *afternoonView = [[CustomView alloc] initWithFrame:CGRectZero];
		afternoonView.title = @"Afternoon";
		afternoonView.image = [UIImage imageNamed:@"12-6PM.png"];
		[viewArray addObject:afternoonView];
		[afternoonView release];

		CustomView *eveningView = [[CustomView alloc] initWithFrame:CGRectZero];
		eveningView.title = @"Evening";
		eveningView.image = [UIImage imageNamed:@"6-12PM.png"];
		[viewArray addObject:eveningView];
		[eveningView release];

		self.customPickerArray = viewArray;
		[viewArray release];
	}
	return self;
}

- (void)dealloc
{
	[customPickerArray release];
	[super dealloc];
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return [CustomView viewWidth];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return [CustomView viewHeight];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [customPickerArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}


#pragma mark -
#pragma mark UIPickerViewDelegate

// tell the picker which view to use for a given component and row, we have an array of views to show
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
		  forComponent:(NSInteger)component reusingView:(UIView *)view
{
	return [customPickerArray objectAtIndex:row];
}

@end
