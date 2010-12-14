//
//  TScriptObject.h
//  GAJavaScript
//
//  Created by Andrew on 12/11/10.
//  Copyright 2010 Goodale Software. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>


@interface TScriptObject : GHAsyncTestCase
	<UIWebViewDelegate>
{
	UIWebView*	m_webView;
	
	SEL			m_curTest;
}

@end
