//
//  RootViewController.m
//  WebView Explorer
//
//  Created by Andrew Goodale on 6/5/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "HtmlElementTableCell.h"
#import "NSObject+GAJavaScript.h"

#define SHOW_ELEMENT    0x00000001

@implementation RootViewController
		
@synthesize detailViewController;
@synthesize document = _document;

- (void)setRootNode:(id)rootNode
{
    // Create the tree walker
    id treeWalker = [_document createTreeWalker:rootNode whatToShow:SHOW_ELEMENT];
    
    NSMutableArray* elems = [[NSMutableArray alloc] initWithCapacity:16];
    
    for (id child = [treeWalker firstChild]; [child isJavaScriptTrue]; child = [treeWalker nextSibling])
    {
        [elems addObject:child];
    }
    
    [_elements release];
    _elements = [elems retain];
    [elems release];
                         
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    detailViewController.rootController = self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [detailViewController release];
    
    [_document release];
    [_elements release];
    
    [super dealloc];
}
		
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

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_elements count];
}
		
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HtmlElementTableCell";
    
    HtmlElementTableCell* cell = (HtmlElementTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[HtmlElementTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                            reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    id childNode = [_elements objectAtIndex:indexPath.row];
    cell.domElement = childNode;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] != UITableViewCellAccessoryDisclosureIndicator)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    RootViewController* nextController = [[RootViewController alloc] initWithStyle:self.tableView.style];
    nextController.document = self.document;
    [nextController setRootNode:[_elements objectAtIndex:indexPath.row]];
    
    [self.navigationController pushViewController:nextController animated:YES];
    [nextController release];
}

@end

#pragma mark -

@implementation DOMTraversal

- (id)createTreeWalker:(id)root whatToShow:(NSInteger)whatToShow
{
    return nil;
}

- (id)firstChild
{
    return nil;
}

- (id)nextSibling
{
    return nil;
}

@end
