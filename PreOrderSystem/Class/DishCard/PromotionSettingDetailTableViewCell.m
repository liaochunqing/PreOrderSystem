//
//  PromotionSettingDetailTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-7-14.
//
//

#import "PromotionSettingDetailTableViewCell.h"
#import "CookbookDataClass.h"

@implementation PromotionSettingDetailTableViewCell
{
    CookbookDataClass *_cookBookData;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateData:(id) info
{
    _cookBookData = (CookbookDataClass *)info;
    
    if ([_cookBookData.cuisineName isKindOfClass:[NSNull class]] == NO)
    {
        self.groupNameLabel.text = _cookBookData.cuisineName;
    }
    
    if ([_cookBookData.cookbookName isKindOfClass:[NSNull class]] == NO)
    {
        self.nameLabel.text = _cookBookData.cookbookName;
    }
    
    if ([_cookBookData.userDefinedPrice isKindOfClass:[NSNull class]] == NO)
    {
        self.nameLabel.text = _cookBookData.userDefinedPrice;
    }
}
@end
