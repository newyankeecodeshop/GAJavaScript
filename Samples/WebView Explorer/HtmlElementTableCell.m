//
//  HtmlElementTableCell.m
//  WebView Explorer
//
//  Created by Andrew Goodale on 9/6/11.
//  Copyright 2011 Wingspan Technology, Inc. All rights reserved.
//

#import "HtmlElementTableCell.h"


@implementation HtmlElementTableCell

@synthesize domElement = _domElement;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) 
    {
        // Initialization code
    }
    
    return self;
}

- (void)dealloc
{
    [_domElement release];
    
    [super dealloc];
}

- (void)setDomElement:(id)domElement
{
    [_domElement release];
    _domElement = [domElement retain];
    
    NSNumber* nodeType = [_domElement valueForKey:@"nodeType"];
    
    if ([nodeType intValue] == ELEMENT_NODE)
    {
        self.textLabel.text = [_domElement valueForKey:@"nodeName"];

        if ([[_domElement valueForKey:@"childElementCount"] intValue] > 0)
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.detailTextLabel.text = @"";
        }
        else
        {
            self.accessoryType = UITableViewCellAccessoryNone;
            self.detailTextLabel.text = [_domElement valueForKey:@"textContent"];
        }
        
    }
    else if ([nodeType intValue] == TEXT_NODE)
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.textLabel.text = [_domElement valueForKey:@"nodeValue"];        
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.textLabel.text = @"";
    }
    
    self.textLabel.font = [UIFont systemFontOfSize:15.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
    {
        [_domElement setValue:@"1px solid blue" forKeyPath:@"style.border"];
    }
    else
    {
        [_domElement setValue:@"0px" forKeyPath:@"style.border"];
    }
}

@end
