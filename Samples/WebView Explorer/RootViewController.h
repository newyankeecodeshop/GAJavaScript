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
    id      _domElement;
    id      _childNodes;
}

@property (nonatomic, retain) IBOutlet DetailViewController*   detailViewController;

@property (nonatomic, retain) id   domElement;

@end
