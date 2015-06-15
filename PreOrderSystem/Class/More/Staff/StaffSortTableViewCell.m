//
//  StaffSortTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import "StaffSortTableViewCell.h"

@implementation StaffSortTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)uopdatePostStyleCell:(NSString *)styleStr withShowLineFlag:(BOOL)lineFlag
{
    self.styleLabel.text = styleStr;
    if (lineFlag)
    {
        self.lineImageView.hidden = NO;
    }
    else
    {
        self.lineImageView.hidden = YES;
    }
}

@end
