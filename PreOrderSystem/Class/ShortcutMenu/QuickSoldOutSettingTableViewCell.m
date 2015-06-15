//
//  EditDiscountTableViewCell.m
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import "QuickSoldOutSettingTableViewCell.h"

@implementation QuickSoldOutSettingTableViewCell

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)soldOutSwitchChanged:(UISwitch *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(QuickSoldOutSettingTableViewCell:soldOutSwitchChanged:)])
    {
        [self.delegate QuickSoldOutSettingTableViewCell:self soldOutSwitchChanged:sender];
    }
}
@end
