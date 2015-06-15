//
//  CouponUseTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-24.
//
//

#import "CouponUseTableViewCell.h"
#import "MemberSuperDataClass.h"
#import "OfflineManager.h"


@interface CouponUseTableViewCell ()
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *couponAmountLabel;//优惠券金额
@property (nonatomic, weak) IBOutlet UILabel *orderCostLabel;//订单总价
@property (nonatomic, weak) IBOutlet UILabel *usedTimeLabel;//使用时间
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;//用户名
@property (nonatomic, weak) IBOutlet UIButton *useDetailBtn;//使用详情

- (IBAction)useDetailBtnBtnClicked:(id)sender;

@end

@implementation CouponUseTableViewCell

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

- (void)updateCouponUseCell:(MemberUseCountDataClass *)useCountClass
{
    self.couponAmountLabel.text = [NSString stringWithFormat:@"%@%@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], useCountClass.couponAmountStr];
    self.orderCostLabel.text = [NSString stringWithFormat:@"%@%@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], useCountClass.orderCostStr];
    self.usedTimeLabel.text = useCountClass.usedTime;
    self.userNameLabel.text = useCountClass.userName;
    [self.useDetailBtn setTitle:kLoc(@"click_to_look") forState:UIControlStateNormal];
}

#pragma mark - UIButton Clicked

- (IBAction)useDetailBtnBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(couponUseTableViewCell:withDetailBtnClicked:)])
    {
        [self.delegate couponUseTableViewCell:self withDetailBtnClicked:self.tag];
    }
}

@end
