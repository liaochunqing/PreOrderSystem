//
//  DtMenuStyleTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import "DtMenuStyleTableViewCell.h"
#import "NsstringAddOn.h"

@implementation DtMenuStyleTableViewCell

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

- (void)uopdateDtMenuStyleCell:(NSString *)styleStr
{
    self.styleLabel.text = styleStr;//[NSString cutString:styleStr withMaxLengthOfStr:kDtMenuCookbookMaxStyleLen];
    self.styleLabel.textAlignment = UITextAlignmentCenter;
}

- (void)setTableViewWidth:(CGFloat)width
{
    CGRect newRect = self.frame;
    CGRect labelRect = self.styleLabel.frame;
    //CGRect imvRect = self.lineImageView.frame;
    //imvRect.size.width = width;
    labelRect.size.width = width;
    newRect.size.width = width;
    //self.lineImageView.frame = imvRect;
    self.styleLabel.frame = labelRect;
    self.frame = newRect;
}

@end
