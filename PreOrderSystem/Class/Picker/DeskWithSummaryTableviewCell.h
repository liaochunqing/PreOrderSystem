//
//  DeskTableviewCell.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeskWithSummaryTableviewCell;

@interface DeskWithSummaryTableviewCell : UITableViewCell{
    __weak UILabel *dtNameLabel;
    __weak UILabel *dtCapacityLabel;
    __weak UILabel *dtMinConsumptionLabel;
    __weak UIImageView *selectedImageview;
    __weak UIImageView *selectImageview;
}

@property(nonatomic, weak) IBOutlet UILabel *dtNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *dtCapacityLabel;
@property(nonatomic, weak) IBOutlet UILabel *dtMinConsumptionLabel;
@property(nonatomic, weak) IBOutlet UIImageView *selectedImageview;
@property(nonatomic, weak) IBOutlet UIImageView *selectImageview;
@property(nonatomic, strong) NSDictionary *deskInfo;

-(void)isSelected:(BOOL)selected;
@end
