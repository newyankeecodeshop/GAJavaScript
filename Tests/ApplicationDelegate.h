//
//  ApplicationDelegate.h
//  GAJavaScript
//
//  Created by Andrew on 5/9/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GHUnitIOS/GHUnitIPhoneAppDelegate.h>

@class GAScriptEngine;

@interface ApplicationDelegate : GHUnitIPhoneAppDelegate
{
    GAScriptEngine*     _scriptEngine;
}

@property (nonatomic, readonly) GAScriptEngine*     scriptEngine;

@end
