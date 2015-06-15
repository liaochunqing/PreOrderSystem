//
//  ReasonTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-11-28.
//
//

#import "ReasonTableViewCell.h"
#import "UIImage+imageWithContentsOfFile.h"

@implementation ReasonTableViewCell

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

- (void)updateViewAfterGetData:(NSString *)reasonStr;
{
    self.reasonLabel.text = reasonStr;
    [self addPictureToView];
}

- (void)addPictureToView
{
    self.titleImageView.image = [UIImage imageFromMainBundleFile:@"order_sexNormalButton.png"];
}

@end
