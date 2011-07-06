//
//  Theme_ExplorerAppDelegate.h
//  Theme Explorer
//
//  Created by Andrew Goodale on 6/23/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAScriptEngine;

@interface ThemeAppDelegate : NSObject <UIApplicationDelegate, UIWebViewDelegate> 
{
@private
    GAScriptEngine*     _scriptEngine;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) GAScriptEngine*   scriptEngine;

@end
