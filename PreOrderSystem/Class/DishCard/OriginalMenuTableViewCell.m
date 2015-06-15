//
//  OriginalMenuTableViewCell.m
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import "OriginalMenuTableViewCell.h"

@implementation OriginalMenuTableViewCell

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
    //self.selectedImageView.hidden = !selected;
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

- (IBAction)didPressSelectedBtn:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:didPressBtn:)])
    {
        [self.delegate tableViewCell:self didPressBtn:sender];
    }
//    if (self.isSelected)
//    {
//        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"dishesPicker_packageNormal.png"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"dishesPicker_packageSelected.png"] forState:UIControlStateNormal];
//    }
//    self.isSelected = !self.isSelected;
}


@end
