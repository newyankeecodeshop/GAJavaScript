//
//  TWebView.h
//  GAJavaScript
//
//  Created by Andrew on 12/12/10.
//  Copyright 2010 Goodale Software. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>


@interface TWebView : GHAsyncTestCase
	<UIWebViewDelegate>
{
	UIWebView*	m_webView;
	
	SEL			m_curTest;
}

@end
