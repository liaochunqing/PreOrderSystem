//
//  AddShortcutMenuTableViewCell.m
//  PreOrderSystem
//
//  Created by mac on 14-7-19.
//
//

#import "AddShortcutMenuTableViewCell.h"

@implementation AddShortcutMenuTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)isSelected:(BOOL)selected
{
    self.isSelected = selected;
    if (!selected)
    {
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"dishesPicker_packageNormal.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"dishesPicker_packageSelected.png"] forState:UIControlStateNormal];
    }
}


- (IBAction)selectedBtnDidPress:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(AddShortcutMenuTableViewCell:didPressBtn:)])
    {
        [self.delegate AddShortcutMenuTableViewCell:self didPressBtn:sender];
    }
    if (self.isSelected)
    {
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"dishesPicker_packageNormal.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"dishesPicker_packageSelected.png"] forState:UIControlStateNormal];
    }
    self.isSelected = !self.isSelected;
}
@end
