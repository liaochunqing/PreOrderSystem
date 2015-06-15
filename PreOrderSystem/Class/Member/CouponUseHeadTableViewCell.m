//
//  CouponUseHeadTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-24.
//
//

#import "CouponUseHeadTableViewCell.h"
#import "MemberSuperDataClass.h"

#define kSortCouponAmountKey @"couponAmount"
#define kSortOrderAmountKey @"orderAmount"
#define kSortUsedTimeKey @"usedTime"

#define kLabelBgColorValue 208.0/255.0

@interface CouponUseHeadTableViewCell ()
{
    MemberCurrentSortDataClass *currentSortClass;
    NSString *currentSortFieldStr;
}

@property (nonatomic, weak) IBOutlet UILabel *couponAmountLabel;//优惠券金额
@property (nonatomic, weak) IBOutlet UIImageView *couponAmountImageView;
@property (nonatomic, weak) IBOutlet UIButton *couponAmountBtn;
@property (nonatomic, weak) IBOutlet UILabel *orderCostLabel;//订单总价
@property (nonatomic, weak) IBOutlet UIImageView *orderCostImageView;
@property (nonatomic, weak) IBOutlet UIButton *orderCostBtn;
@property (nonatomic, weak) IBOutlet UILabel *usedTimeLabel;//使用时间
@property (nonatomic, weak) IBOutlet UIImageView *usedTimeImageView;
@property (nonatomic, weak) IBOutlet UIButton *usedTimeBtn;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;//用户名
@property (nonatomic, weak) IBOutlet UILabel *useDetailLabel;//使用详情

- (IBAction)couponAmountBtnClicked:(id)sender;
- (IBAction)orderCostBtnClicked:(id)sender;
- (IBAction)usedTimeBtnClicked:(id)sender;

@end

@implementation CouponUseHeadTableViewCell

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

- (void)updateCouponUserHeadCell:(MemberCurrentSortDataClass *)sortClass
{
    self.couponAmountLabel.text = kLoc(@"coupons_money");
    self.orderCostLabel.text = kLoc(@"order_total_price");
    self.usedTimeLabel.text = kLoc(@"use_of_date");
    self.userNameLabel.text = kLoc(@"user_name");
    self.useDetailLabel.text = kLoc(@"use_of_detail");
    currentSortClass = sortClass;
    currentSortFieldStr = currentSortClass.fieldStr;
    
    self.couponAmountImageView.image = self.orderCostImageView.image = self.usedTimeImageView.image = [UIImage imageNamed:@"member_blackDownArrow.png"];
    UIImage *selectedImg = [UIImage imageNamed:(sortClass.orderFlag?@"member_orangeDownArrow.png":@"member_orangeUpArrow.png")];
//    UIColor *color = sortClass.orderFlag? [UIColor blackColor] : [UIColor orangeColor];
    if ([sortClass.fieldStr isEqualToString:kSortCouponAmountKey])
    {
        self.couponAmountImageView.image = selectedImg;
        self.couponAmountLabel.backgroundColor = [UIColor whiteColor];
        self.orderCostLabel.backgroundColor = self.usedTimeLabel.backgroundColor = [UIColor colorWithRed:kLabelBgColorValue green:kLabelBgColorValue blue:kLabelBgColorValue alpha:1.0];
        
        self.couponAmountLabel.textColor = [UIColor orangeColor];
        self.orderCostLabel.textColor = self.usedTimeLabel.textColor = [UIColor blackColor];
    }
    else if ([sortClass.fieldStr isEqualToString:kSortOrderAmountKey])
    {
        self.orderCostImageView.image = selectedImg;
        self.orderCostLabel.backgroundColor = [UIColor whiteColor];
        self.orderCostLabel.textColor = [UIColor orangeColor];
        self.couponAmountLabel.backgroundColor = self.usedTimeLabel.backgroundColor = [UIColor colorWithRed:kLabelBgColorValue green:kLabelBgColorValue blue:kLabelBgColorValue alpha:1.0];
        
        self.orderCostLabel.textColor = [UIColor orangeColor];
        self.couponAmountLabel.textColor = self.usedTimeLabel.textColor = [UIColor blackColor];
    }
    else if ([sortClass.fieldStr isEqualToString:kSortUsedTimeKey])
    {
        self.usedTimeImageView.image = selectedImg;
        self.usedTimeLabel.backgroundColor = [UIColor whiteColor];
        self.usedTimeLabel.textColor = [UIColor orangeColor];
        self.couponAmountLabel.backgroundColor = self.orderCostLabel.backgroundColor = [UIColor colorWithRed:kLabelBgColorValue green:kLabelBgColorValue blue:kLabelBgColorValue alpha:1.0];
        
        self.usedTimeLabel.textColor = [UIColor orangeColor];
        self.couponAmountLabel.textColor = self.orderCostLabel.textColor = [UIColor blackColor];
    }
}

- (void)updateSortChanged:(NSString *)sortKey
{
    currentSortClass.fieldStr = sortKey;
    if ([currentSortFieldStr isEqualToString:sortKey])
    {
        currentSortClass.orderFlag = !currentSortClass.orderFlag;
    }
    else
    {
        currentSortClass.orderFlag = NO;
    }
    if ([self.delegate respondsToSelector:@selector(couponUseHeadTableViewCell:withSortHavedChanged:)])
    {
        [self.delegate couponUseHeadTableViewCell:self withSortHavedChanged:YES];
    }
}

#pragma mark - UIButton Clicked

- (IBAction)couponAmountBtnClicked:(id)sender
{
    [self updateSortChanged:kSortCouponAmountKey];
}

- (IBAction)orderCostBtnClicked:(id)sender
{
    [self updateSortChanged:kSortOrderAmountKey];
}

- (IBAction)usedTimeBtnClicked:(id)sender
{
    [self updateSortChanged:kSortUsedTimeKey];
}

@end
