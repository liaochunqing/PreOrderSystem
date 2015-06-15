//
//  TaskListLoadMoreCell.m
//  EasyWork2
//
//  Created by AaronKwok on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OrderListLoadMoreCell.h"

@implementation OrderListLoadMoreCell
@synthesize messageLabel;
@synthesize spinner;

-(void)loadText:(NSString *)message
{
    messageLabel.text = message;
}

-(void)loadTextWithOutData:(NSString *)message
{
    messageLabel.text = message;
}

-(void)startLoading:(NSString *)message
{
    messageLabel.text = message;
    [spinner startAnimating];
}


-(void)stopLoading:(NSString *)message
{
    messageLabel.text = message;
    [spinner stopAnimating];
}

@end
