//
//  HtmlElementTableCell.h
//  WebView Explorer
//
//  Created by Andrew Goodale on 9/6/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

enum DomNodeType
{
    ELEMENT_NODE    = 1,
    ATTRIBUTE_NODE  = 2,
    TEXT_NODE       = 3,
    COMMENT_NODE    = 8
};

@interface HtmlElementTableCell : UITableViewCell 
{
@private
    id      _domElement;
}

@property (nonatomic, retain) id domElement;

@end
