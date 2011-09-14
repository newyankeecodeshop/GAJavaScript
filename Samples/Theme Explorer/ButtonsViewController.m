/*
     File: ButtonsViewController.m 
 Abstract: The table view controller for hosting the UIButton features of this sample. 
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

#import "ButtonsViewController.h"
#import "Constants.h"

#define kStdButtonWidth		106.0
#define kStdButtonHeight	40.0

#define kViewTag			1		// for tagging our embedded controls for removal at cell recycle time

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kLabelKey = @"labelKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

#pragma mark -

@implementation ButtonsViewController

@synthesize dataSourceArray;

- (void)dealloc
{
	[grayButton release];
	[imageButton release];
	[roundedButtonType release];
	
	[detailDisclosureButtonType release];
	[infoLightButtonType release];
	[infoDarkButtonType release];
	[contactAddButtonType release];
	
	[dataSourceArray release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"ButtonsTitle", @"");
	
	self.dataSourceArray = [NSArray arrayWithObjects:
									[NSDictionary dictionaryWithObjectsAndKeys:
										@"UIButton", kSectionTitleKey,
										@"Background Image", kLabelKey,
										@"ButtonsViewController.m:\r(UIButton *)grayButton", kSourceKey,
										self.grayButton, kViewKey,
									  nil],
								
									[NSDictionary dictionaryWithObjectsAndKeys:
										@"UIButton", kSectionTitleKey,
										@"Button with Image", kLabelKey,
										@"ButtonsViewController.m:\r(UIButton *)imageButton", kSourceKey,
										self.imageButton, kViewKey,
									 nil],
								
									[NSDictionary dictionaryWithObjectsAndKeys:
										@"UIButtonTypeRoundedRect", kSectionTitleKey,
										@"Rounded Button", kLabelKey,
										@"ButtonsViewController.m:\r(UIButton *)roundedButtonType", kSourceKey,
										self.roundedButtonType, kViewKey,
									 nil],
									
									[NSDictionary dictionaryWithObjectsAndKeys:
										@"UIButtonTypeDetailDisclosure", kSectionTitleKey,
										@"Detail Disclosure", kLabelKey,
										@"ButtonsViewController.m:\r(UIButton *)detailDisclosureButton", kSourceKey,
										self.detailDisclosureButtonType, kViewKey,
									 nil],
									
									[NSDictionary dictionaryWithObjectsAndKeys:
										@"UIButtonTypeInfoLight", kSectionTitleKey,
										@"Info Light", kLabelKey,
										@"ButtonsViewController.m:\r(UIButton *)infoLightButtonType", kSourceKey,
										self.infoLightButtonType, kViewKey,
									 nil],
								
									[NSDictionary dictionaryWithObjectsAndKeys:
										@"UIButtonTypeInfoDark", kSectionTitleKey,
										@"Info Dark", kLabelKey,
										@"ButtonsViewController.m:\r(UIButton *)infoDarkButtonType", kSourceKey,
										self.infoDarkButtonType, kViewKey,
									 nil],
									
									[NSDictionary dictionaryWithObjectsAndKeys:
										@"UIButtonTypeContactAdd", kSectionTitleKey,
										@"Contact Add", kLabelKey,
										@"ButtonsViewController.m:\r(UIButton *)contactAddButtonType", kSourceKey,
										self.contactAddButtonType, kViewKey,
									 nil],
								nil];
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
	[grayButton release];
	grayButton = nil;
	[imageButton release];
	imageButton = nil;
	[roundedButtonType release];
	roundedButtonType = nil;
	[detailDisclosureButtonType release];
	detailDisclosureButtonType = nil;
	[infoLightButtonType release];
	infoLightButtonType = nil;
	[infoDarkButtonType release];
	infoDarkButtonType = nil;
	[contactAddButtonType release];
	contactAddButtonType = nil;
	
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
	return ([indexPath row] == 0) ? 50.0 : 38.0;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	if ([indexPath row] == 0)
	{
		static NSString *kDisplayCell_ID = @"DisplayCellID";
		cell = [self.tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
        if (cell == nil)
        {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCell_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
		else
		{
			// the cell is being recycled, remove old embedded controls
			UIView *viewToRemove = nil;
			viewToRemove = [cell.contentView viewWithTag:kViewTag];
			if (viewToRemove)
				[viewToRemove removeFromSuperview];
		}
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kLabelKey];
		
		UIButton *button = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kViewKey];
		[cell.contentView addSubview:button];
	}
	else
	{
		static NSString *kSourceCellID = @"SourceCellID";
		cell = [self.tableView dequeueReusableCellWithIdentifier:kSourceCellID];
        if (cell == nil)
        {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			cell.textLabel.opaque = NO;
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.numberOfLines = 2;
			cell.textLabel.highlightedTextColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        }
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kSourceKey];
	}

	return cell;
}


#pragma mark -

+ (UIButton *)newButtonWithTitle:(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
						image:(UIImage *)image
				 imagePressed:(UIImage *)imagePressed
				darkTextColor:(BOOL)darkTextColor
{	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	// or you can do this:
	//		UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}

- (void)action:(id)sender
{
	//NSLog(@"UIButton was clicked");
}

#pragma mark -
#pragma mark Lazy creation of buttons

- (UIButton *)grayButton
{	
	if (grayButton == nil)
	{
		// create the UIButtons with various background images
		// white button:
		UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
		UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
		
		CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
		
		grayButton = [ButtonsViewController newButtonWithTitle:@"Gray"
													 target:self
												   selector:@selector(action:)
													  frame:frame
													  image:buttonBackground
											   imagePressed:buttonBackgroundPressed
											  darkTextColor:YES];
		
		grayButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	return grayButton;
}

- (UIButton *)imageButton
{	
	if (imageButton == nil)
	{
		// create a UIButton with just an image instead of a title
		
		UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
		UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
		
		CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
		
		imageButton = [ButtonsViewController newButtonWithTitle:@""
													  target:self
													selector:@selector(action:)
													   frame:frame
													   image:buttonBackground
												imagePressed:buttonBackgroundPressed
											   darkTextColor:YES];
		
		[imageButton setImage:[UIImage imageNamed:@"UIButton_custom.png"] forState:UIControlStateNormal];
		
		// Add an accessibility label to the image.
		[imageButton setAccessibilityLabel:NSLocalizedString(@"ArrowButton", @"")];
		
		imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	return imageButton;
}

- (UIButton *)roundedButtonType
{
	if (roundedButtonType == nil)
	{
		// create a UIButton (UIButtonTypeRoundedRect)
		roundedButtonType = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		roundedButtonType.frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
		[roundedButtonType setTitle:@"Rounded" forState:UIControlStateNormal];
		roundedButtonType.backgroundColor = [UIColor clearColor];
		[roundedButtonType addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
		
		roundedButtonType.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	return roundedButtonType;
}

- (UIButton *)detailDisclosureButtonType
{
	if (detailDisclosureButtonType == nil)
	{
		// create a UIButton (UIButtonTypeDetailDisclosure)
		detailDisclosureButtonType = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain];
		detailDisclosureButtonType.frame = CGRectMake(250.0, 8.0, 25.0, 25.0);
		[detailDisclosureButtonType setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		detailDisclosureButtonType.backgroundColor = [UIColor clearColor];
		[detailDisclosureButtonType addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
		
		// Add a custom accessibility label to the button because it has no associated text.
		[detailDisclosureButtonType setAccessibilityLabel:NSLocalizedString(@"MoreInfoButton", @"")];

		detailDisclosureButtonType.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	return detailDisclosureButtonType;
}

- (UIButton *)infoDarkButtonType
{
	if (infoDarkButtonType == nil)
	{
		// create a UIButton (UIButtonTypeInfoLight)
		infoDarkButtonType = [[UIButton buttonWithType:UIButtonTypeInfoDark] retain];
		infoDarkButtonType.frame = CGRectMake(250.0, 8.0, 25.0, 25.0);
		[infoDarkButtonType setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		infoDarkButtonType.backgroundColor = [UIColor clearColor];
		[infoDarkButtonType addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
		
		// Add a custom accessibility label to the button because it has no associated text.
		[infoDarkButtonType setAccessibilityLabel:NSLocalizedString(@"MoreInfoButton", @"")];

		infoDarkButtonType.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	return infoDarkButtonType;
}

- (UIButton *)infoLightButtonType
{
	if (infoLightButtonType == nil)
	{
		// create a UIButton (UIButtonTypeInfoLight)
		infoLightButtonType = [[UIButton buttonWithType:UIButtonTypeInfoLight] retain];
		infoLightButtonType.frame = CGRectMake(250.0, 8.0, 25.0, 25.0);
		[infoLightButtonType setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		infoLightButtonType.backgroundColor = [UIColor clearColor];
		[infoLightButtonType addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
		infoLightButtonType.backgroundColor = [UIColor grayColor];
		
		// Add a custom accessibility label to the button because it has no associated text.
		[infoLightButtonType setAccessibilityLabel:NSLocalizedString(@"MoreInfoButton", @"")];

		infoLightButtonType.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	
	return infoLightButtonType;
}

- (UIButton *)contactAddButtonType
{
	if (contactAddButtonType == nil)
	{
		// create a UIButton (UIButtonTypeContactAdd)
		contactAddButtonType = [[UIButton buttonWithType:UIButtonTypeContactAdd] retain];
		contactAddButtonType.frame = CGRectMake(250.0, 8.0, 25.0, 25.0);
		[contactAddButtonType setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		contactAddButtonType.backgroundColor = [UIColor clearColor];
		[contactAddButtonType addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
		
		// Add a custom accessibility label to the button because it has no associated text.
		[contactAddButtonType setAccessibilityLabel:NSLocalizedString(@"AddContactButton", @"")];
		
		contactAddButtonType.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
	return contactAddButtonType;
}

@end

