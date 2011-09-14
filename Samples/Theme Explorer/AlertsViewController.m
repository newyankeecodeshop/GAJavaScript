/*
     File: AlertsViewController.m 
 Abstract: The view controller for hosting various kinds of alerts and action sheets 
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

#import "AlertsViewController.h"

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kLabelKey = @"labelKey";
static NSString *kSourceKey = @"sourceKey";

enum AlertTableSections
{
	kUIAction_Simple_Section = 0,
	kUIAction_OKCancel_Section,
	kUIAction_Custom_Section,
	kUIAlert_Simple_Section,
	kUIAlert_OKCancel_Section,
	kUIAlert_Custom_Section,
};

@implementation AlertsViewController

@synthesize dataSourceArray;

- (void)dealloc
{	
	[dataSourceArray release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"AlertTitle", @"");

	self.dataSourceArray = [NSArray arrayWithObjects:
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UIActionSheet", kSectionTitleKey,
								 @"Show Simple", kLabelKey,
								 @"AlertsViewController.m - dialogSimpleAction", kSourceKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UIActionSheet", kSectionTitleKey,
								 @"Show OK-Cancel", kLabelKey,
								 @"AlertsViewController.m - dialogOKCancelAction", kSourceKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UIActionSheet", kSectionTitleKey,
								 @"Show Customized", kLabelKey,
								 @"AlertsViewController.m - dialogOtherAction", kSourceKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UIAlertView", kSectionTitleKey,
								 @"Show Simple", kLabelKey,
								 @"AlertsViewController.m - alertSimpleAction", kSourceKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UIAlertView", kSectionTitleKey,
								 @"Show OK-Cancel", kLabelKey,
								 @"AlertsViewController.m - alertOKCancelAction", kSourceKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UIAlertView", kSectionTitleKey,
								 @"Show Custom", kLabelKey,
								 @"AlertsViewController.m - alertOtherAction", kSourceKey,
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
	
	self.dataSourceArray = nil;	// this will release and set to nil
}


#pragma mark -
#pragma mark UIActionSheet

- (void)dialogSimpleAction
{
	// open a dialog with just an OK button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"UIActionSheet <title>"
									delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
	[actionSheet release];
}

- (void)dialogOKCancelAction
{
	// open a dialog with an OK and cancel button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"UIActionSheet <title>"
									delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"OK" otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
}

- (void)dialogOtherAction
{
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"UIActionSheet <title>"
									delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
									otherButtonTitles:@"Button1", @"Button2", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.destructiveButtonIndex = 1;	// make the second button red (destructive)
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
}


#pragma mark -
#pragma mark UIAlertView

- (void)alertSimpleAction
{
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:@"<Alert message>"
							delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

- (void)alertOKCancelAction
{
	// open a alert with an OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:@"<Alert message>"
							delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

- (void)alertOtherAction
{
	// open an alert with two custom buttons
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:@"<Alert message>"
							delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Button1", @"Button2", nil];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		//NSLog(@"ok");
	}
	else
	{
		//NSLog(@"cancel");
	}
}


#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
}


#pragma mark -
#pragma mark - UITableView delegates

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

// the table's selection has changed, show the alert or action sheet
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// deselect the current row (don't keep the table selection persistent)
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	if (indexPath.row == 0)
	{
		switch (indexPath.section)
		{
			case kUIAction_Simple_Section:
			{
				[self dialogSimpleAction];
                break;
			}
				
			case kUIAction_OKCancel_Section:
			{
				[self dialogOKCancelAction];
				break;
			}
				
			case kUIAction_Custom_Section:
			{
				[self dialogOtherAction];
				break;
			}
				
			case kUIAlert_Simple_Section:
			{
				[self alertSimpleAction];
				break;
			}
				
			case kUIAlert_OKCancel_Section:
			{
				[self alertOKCancelAction];	
				break;
			}
				
			case kUIAlert_Custom_Section:
			{
				[self alertOtherAction];	
				break;
			}
		}
	}
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	if ([indexPath row] == 0)
	{
		static NSString *kAlertCell_ID = @"AlertCell_ID";
		cell = [self.tableView dequeueReusableCellWithIdentifier:kAlertCell_ID];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAlertCell_ID] autorelease];
		}
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kLabelKey];
	}	
	else
	{
		static NSString *kSourceCell_ID = @"SourceCell_ID";
		cell = [self.tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			cell.textLabel.opaque = NO;
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.numberOfLines = 2;
            cell.textLabel.font = [UIFont systemFontOfSize:12];
		}
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kSourceKey];
	}
	
	return cell;
}

@end

