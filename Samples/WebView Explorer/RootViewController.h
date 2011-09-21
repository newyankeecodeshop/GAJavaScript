//
//  RootViewController.h
//  WebView Explorer
//
//  Created by Andrew Goodale on 6/5/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController 
{
    id          _document;
    NSArray*    _elements;
}

@property (nonatomic, retain) IBOutlet DetailViewController*   detailViewController;

@property (nonatomic, retain) id   document;

- (void)setRootNode:(id)rootNode;

@end

#pragma mark -

@interface DOMTraversal : NSObject 
{

}

- (id)createTreeWalker:(id)root whatToShow:(NSInteger)whatToShow;

- (id)firstChild;

- (id)nextSibling;

@end