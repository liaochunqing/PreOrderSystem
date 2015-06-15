//
//  CouponHeadTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-24.
//
//

#import "CouponHeadTableViewCell.h"

@interface CouponHeadTableViewCell ()
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;//优惠券名称
@property (nonatomic, weak) IBOutlet UILabel *quantityLabel;//总数
@property (nonatomic, weak) IBOutlet UILabel *usedLabel;//使用数
@property (nonatomic, weak) IBOutlet UILabel *surplusLabel;//剩余数

@end

@implementation CouponHeadTableViewCell

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

- (void)updateCouponHeadCell
{
    self.nameLabel.text = kLoc(@"coupons");
    self.quantityLabel.text = kLoc(@"issue_number");
    self.usedLabel.text = kLoc(@"use_of_number");
    self.surplusLabel.text = kLoc(@"number_remaining");
}

@end
