//
//  CouponTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-24.
//
//

#import "CouponTableViewCell.h"
#import "MemberSuperDataClass.h"

@interface CouponTableViewCell ()
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;//优惠券名称
@property (nonatomic, weak) IBOutlet UILabel *quantityLabel;//总数
@property (nonatomic, weak) IBOutlet UILabel *usedLabel;//使用数
@property (nonatomic, weak) IBOutlet UILabel *surplusLabel;//剩余数

@end

@implementation CouponTableViewCell

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

- (void)updateCouponCell:(MemberTypeCountDataClass *)typeCountClass
{
    self.nameLabel.text = typeCountClass.name;
    self.quantityLabel.text = [NSString stringWithFormat:@"%d", typeCountClass.quantity];
    self.usedLabel.text = [NSString stringWithFormat:@"%d", typeCountClass.used];
    self.surplusLabel.text = [NSString stringWithFormat:@"%d", typeCountClass.remain];
}

@end
