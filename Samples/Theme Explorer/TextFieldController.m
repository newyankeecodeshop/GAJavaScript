/*
     File: TextFieldController.m 
 Abstract: The view controller for hosting the UITextField features of this sample. 
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

#import "TextFieldController.h"
#import "Constants.h"

#define kTextFieldWidth	260.0

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

const NSInteger kViewTag = 1;

@implementation TextFieldController

@synthesize textFieldNormal, textFieldRounded, textFieldSecure, textFieldLeftView, dataSourceArray;

- (void)dealloc
{
	[textFieldNormal release];
	[textFieldRounded release];
	[textFieldSecure release];
	[textFieldLeftView release];
	
	[dataSourceArray release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.dataSourceArray = [NSArray arrayWithObjects:
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UITextField", kSectionTitleKey,
								 @"TextFieldController.m: textFieldNormal", kSourceKey,
								 self.textFieldNormal, kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UITextField Rounded", kSectionTitleKey,
								 @"TextFieldController.m: textFieldRounded", kSourceKey,
								 self.textFieldRounded, kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UITextField Secure", kSectionTitleKey,
								 @"TextFieldController.m: textFieldSecure", kSourceKey,
								 self.textFieldSecure, kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UITextField (with LeftView)", kSectionTitleKey,
								 @"TextFieldController.m: textFieldLeftView", kSourceKey,
								 self.textFieldLeftView, kViewKey,
								 nil],
							nil];
	
	self.title = NSLocalizedString(@"TextFieldTitle", @"");
	
	// we aren't editing any fields yet, it will be in edit when the user touches an edit field
	self.editing = NO;
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// release the controls and set them nil in case they were ever created
	// note: we can't use "self.xxx = nil" since they are read only properties
	//
	[textFieldNormal release];
	textFieldNormal = nil;		
	[textFieldRounded release];
	textFieldRounded = nil;
	[textFieldSecure release];
	textFieldSecure = nil;
	[textFieldLeftView release];
	textFieldLeftView = nil;
	
	self.dataSourceArray = nil;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.dataSourceArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.dataSourceArray objectAtIndex: section] valueForKey:kSectionTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ([indexPath row] == 0) ? 50.0 : 22.0;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	NSUInteger row = [indexPath row];
	if (row == 0)
	{
		static NSString *kCellTextField_ID = @"CellTextField_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		if (cell == nil)
		{
			// a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:kCellTextField_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else
		{
			// a cell is being recycled, remove the old edit field (if it contains one of our tagged edit fields)
			UIView *viewToCheck = nil;
			viewToCheck = [cell.contentView viewWithTag:kViewTag];
			if (viewToCheck)
				[viewToCheck removeFromSuperview];
		}
		
		UITextField *textField = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kViewKey];
		[cell.contentView addSubview:textField];
	}
	else /* (row == 1) */
	{
		static NSString *kSourceCell_ID = @"SourceCell_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:kSourceCell_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.highlightedTextColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12.0];
		}
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kSourceKey];
	}
	
    return cell;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}


#pragma mark -
#pragma mark Text Fields

- (UITextField *)textFieldNormal
{
	if (textFieldNormal == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldNormal = [[UITextField alloc] initWithFrame:frame];
		
		textFieldNormal.borderStyle = UITextBorderStyleBezel;
		textFieldNormal.textColor = [UIColor blackColor];
		textFieldNormal.font = [UIFont systemFontOfSize:17.0];
		textFieldNormal.placeholder = @"<enter text>";
		textFieldNormal.backgroundColor = [UIColor whiteColor];
		textFieldNormal.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		
		textFieldNormal.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
		textFieldNormal.returnKeyType = UIReturnKeyDone;
		
		textFieldNormal.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldNormal.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldNormal.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldNormal setAccessibilityLabel:NSLocalizedString(@"NormalTextField", @"")];
	}	
	return textFieldNormal;
}

- (UITextField *)textFieldRounded
{
	if (textFieldRounded == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldRounded = [[UITextField alloc] initWithFrame:frame];
		
		textFieldRounded.borderStyle = UITextBorderStyleRoundedRect;
		textFieldRounded.textColor = [UIColor blackColor];
		textFieldRounded.font = [UIFont systemFontOfSize:17.0];
		textFieldRounded.placeholder = @"<enter text>";
		textFieldRounded.backgroundColor = [UIColor whiteColor];
		textFieldRounded.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		
		textFieldRounded.keyboardType = UIKeyboardTypeDefault;
		textFieldRounded.returnKeyType = UIReturnKeyDone;
		
		textFieldRounded.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldRounded.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldRounded.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldRounded setAccessibilityLabel:NSLocalizedString(@"RoundedTextField", @"")];
	}
	return textFieldRounded;
}

- (UITextField *)textFieldSecure
{
	if (textFieldSecure == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldSecure = [[UITextField alloc] initWithFrame:frame];
		textFieldSecure.borderStyle = UITextBorderStyleBezel;
		textFieldSecure.textColor = [UIColor blackColor];
		textFieldSecure.font = [UIFont systemFontOfSize:17.0];
		textFieldSecure.placeholder = @"<enter password>";
		textFieldSecure.backgroundColor = [UIColor whiteColor];
		
		textFieldSecure.keyboardType = UIKeyboardTypeDefault;
		textFieldSecure.returnKeyType = UIReturnKeyDone;	
		textFieldSecure.secureTextEntry = YES;	// make the text entry secure (bullets)
		
		textFieldSecure.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldSecure.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldSecure.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldSecure setAccessibilityLabel:NSLocalizedString(@"SecureTextField", @"")];
	}
	return textFieldSecure;
}

- (UITextField *)textFieldLeftView
{
	if (textFieldLeftView == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldLeftView = [[UITextField alloc] initWithFrame:frame];
		textFieldLeftView.borderStyle = UITextBorderStyleBezel;
		textFieldLeftView.textColor = [UIColor blackColor];
		textFieldLeftView.font = [UIFont systemFontOfSize:17.0];
		textFieldLeftView.placeholder = @"<enter text>";
		textFieldLeftView.backgroundColor = [UIColor whiteColor];
		
		textFieldLeftView.keyboardType = UIKeyboardTypeDefault;
		textFieldLeftView.returnKeyType = UIReturnKeyDone;	
		
		textFieldLeftView.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldLeftView.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		// Add an accessibility label that describes the text field.
		[textFieldLeftView setAccessibilityLabel:NSLocalizedString(@"CheckMarkIcon", @"")];
		
		textFieldLeftView.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment_check.png"]];
		textFieldLeftView.leftViewMode = UITextFieldViewModeAlways;
		
		textFieldLeftView.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	}
	return textFieldLeftView;
}

@end

