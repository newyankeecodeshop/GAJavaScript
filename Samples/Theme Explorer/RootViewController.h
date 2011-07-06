//
//  RootViewController.h
//  Theme Explorer
//
//  Created by Andrew Goodale on 6/23/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAScriptEngine;

@interface RootViewController : UITableViewController 
{
@private
    GAScriptEngine*     _scriptEngine;      // Not retaineds
}


@end
