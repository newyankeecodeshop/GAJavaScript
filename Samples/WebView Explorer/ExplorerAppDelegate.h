//
//  WebView_ExplorerAppDelegate.h
//  WebView Explorer
//
//  Created by Andrew Goodale on 6/5/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@class DetailViewController;

@interface ExplorerAppDelegate : NSObject <UIApplicationDelegate> 
{

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
