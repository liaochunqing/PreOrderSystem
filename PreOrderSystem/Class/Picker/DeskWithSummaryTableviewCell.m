//
//  DeskTableviewCell.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DeskWithSummaryTableviewCell.h"

@interface DeskWithSummaryTableviewCell (Private)
@end

@implementation DeskWithSummaryTableviewCell
@synthesize deskInfo;
@synthesize dtCapacityLabel;
@synthesize dtMinConsumptionLabel;
@synthesize selectedImageview;
@synthesize dtNameLabel;
@synthesize selectImageview;

-(void)setDeskInfo:(NSDictionary *)info{
    dtNameLabel.text = [info objectForKey:@"seatsName"];
    
    int minCapacity = [[info objectForKey:@"capacity1"] intValue];
    int maxCapacity = [[info objectForKey:@"capacity2"] intValue];
    dtCapacityLabel.text = [NSString stringWithFormat:@"%i人 - %i人", minCapacity, maxCapacity];
    
    int minConsumption = [[info objectForKey:@"minimumConsumption"] intValue];
    if (minConsumption != 0)
    {
         dtMinConsumptionLabel.text = [NSString stringWithFormat:@"低消 %i元", minConsumption];
    }
    else
    {
        dtMinConsumptionLabel.text = @"";
        CGRect frame = dtCapacityLabel.frame;
        frame.origin.y += 15;
        dtCapacityLabel.frame = frame;
    }
    if (0 == [[info objectForKey:@"status"] intValue])
    {
        dtNameLabel.textColor =[UIColor colorWithRed:18.0/255.0 green:137.0/255.0 blue:166.0/255.0 alpha:1.0];
        dtCapacityLabel.textColor =[UIColor colorWithRed:18.0/255.0 green:137.0/255.0 blue:166.0/255.0 alpha:1.0];
        dtMinConsumptionLabel.textColor =[UIColor colorWithRed:18.0/255.0 green:137.0/255.0 blue:166.0/255.0 alpha:1.0];
    }
    else
    {
        dtNameLabel.textColor =[UIColor blackColor];
        dtCapacityLabel.textColor =[UIColor darkGrayColor];
        dtMinConsumptionLabel.textColor =[UIColor darkGrayColor];
    }
}


-(void)isSelected:(BOOL)selected{
    selectedImageview.hidden = !selected;
}

@end
