//
//  DeskTableviewCell.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DeskTableviewCell.h"

@interface DeskTableviewCell (Private)
-(IBAction)selectedButtonPressed:(UIButton*)sender;
@end

@implementation DeskTableviewCell
@synthesize delegate;
@synthesize deskInfo;
@synthesize selectedImageview;
@synthesize dtNameLabel;
@synthesize normalImageview;

-(void)setDeskInfo:(NSDictionary *)info{
    dtNameLabel.text = [info objectForKey:@"seatsName"];
}



-(void)isSelected:(BOOL)selected{
    selectedImageview.hidden = !selected;
}

-(void)setDeskTitle:(NSString*)text{
    dtNameLabel.text = text;
}
@end
