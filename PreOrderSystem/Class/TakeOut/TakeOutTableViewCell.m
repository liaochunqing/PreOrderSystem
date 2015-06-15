//
//  TakeOutTableViewCell.m
//  PreOrderSystem
//
//  Created by sWen on 12-12-11.
//
//

#import "TakeOutTableViewCell.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"

@implementation TakeOutTableViewCell

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

- (void)addLocalizedString
{
    self.deliveryTypeLabel.text = [NSString stringWithFormat:@"(%@)",kLoc(@"self_pick")];

}

- (void)addPictureToView
{
    self.isCheckedImageview.image = [UIImage imageNamed:@"order_unreadTagImageView.png"];
    self.stateBgImageView.image = [UIImage imageNamed:@"order_state1.png"];
    self.payMentImageView.image = [UIImage imageNamed:@"order_payment.png"];
    self.isRemindersImageView.image = [UIImage imageNamed:@"takeout_reminder.png"];
    self.lineBgImageView.image = [UIImage imageNamed:@"order_dash.png"];
}

-(void)updateOrderMsgInfo:(NSDictionary *)info
{
    self.backgroundColor = [UIColor clearColor];
    if (info != nil) {
        [self addLocalizedString];
        [self addPictureToView];
        
        // 是否未读
        int isChecked = [[info objectForKey:@"isChecked"] intValue];
        self.isCheckedImageview.hidden = (0 == isChecked) ? NO : YES;
        // 是否已经支付订单/是否为电话外卖/或者都不是（只有一种可能）
        int isPayment = [[info objectForKey:@"onlinePaid"] intValue];
        int isByPhone = [[info objectForKey:@"byphone"] intValue];
        if (isPayment == 1) {
            self.payMentImageView.hidden = NO;
            self.payMentImageView.image = [UIImage imageNamed:@"order_payment.png"];
        } else if (isByPhone == 1) {
            self.payMentImageView.hidden = NO;
            self.payMentImageView.image = [UIImage imageNamed:@"order_call.png"];
        } else {
            self.payMentImageView.hidden = YES;
        }
        
        // 是否催单
        int isReminder = [[info objectForKey:@"reminderStatus"] intValue];
        self.isRemindersImageView.hidden = (1 == isReminder) ? NO : YES;
        
        // 称呼
        self.firstNameLabel.text = [info objectForKey:@"guestName"];
        // 性别
        int sex = [[info objectForKey:@"guestSex"] intValue];
        
        if ([[info objectForKey:@"guestName"] length] > 3) {
            CGRect frame2 = self.firstNameLabel.frame;
            frame2.size.width += 50;
            self.firstNameLabel.frame = frame2;
            
            CGRect frame = self.sexLabel.frame;
            frame.origin.y = CGRectGetMaxY(self.firstNameLabel.frame) + 2;
            frame.origin.x = self.firstNameLabel.frame.origin.x + 3;
            self.sexLabel.frame = frame;
        }
        
        switch (sex) {
            case 1:
                self.sexLabel.text = kLoc(@"mister");
                break;
            case 2:
                self.sexLabel.text = kLoc(@"lady");
                break;
            default:
                self.sexLabel.text = @"";
                break;
        }
        // 电话
        self.phoneLabel.text = [info objectForKey:@"guestPhone"];
        
        // 送达时间
        NSInteger mealDateType = [[info objectForKey:@"carryTimeType"] integerValue];
        
        if (0 == mealDateType)
        {
            NSString *mealDateStr = [info objectForKey:@"carryTime"];
            NSDate *mealDate = [mealDateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
            //self.preOrderHourDateLabel.text = [NSString dateToNSString:mealDate withFormat:@"HH:mm"];
            self.inDateLabel.text = [NSString dateToNSString:mealDate withFormat:@"MM-dd eee"];
            self.preOrderHourDateLabel.text = [NSString dateToNSString:mealDate withFormat:@"HH:mm"];
        }
        else
        {
            NSString *mealDateStr = [info objectForKey:@"carryTime"];
            NSDate *mealDate = [mealDateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
            NSString *dateTime =  [NSString dateToNSString:mealDate withFormat:@"MM-dd eee"];
            NSString *takeoutTimeTypeDesc = [info objectForKey:@"carryTimeTypeDesc"];
            self.inDateLabel.text = dateTime;
            self.preOrderHourDateLabel.text = takeoutTimeTypeDesc;
        }
        
        // 下单时间
        NSString *createdDateStr = [info objectForKey:@"orderTime"];
        NSDate *createdDate = [createdDateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
        self.orderDateLabel.text = [NSString dateToNSString:createdDate withFormat:@"MM-dd\nHH:mm"];
        
        // 订单状态
        int status = [[info objectForKey:@"status"] intValue];
        if (status == 0) {
            self.stateBgImageView.hidden = NO;
            self.stateBgImageView.image = [UIImage imageNamed:@"order_state1.png"];
            
            self.orderStatusLabel.textColor = [UIColor whiteColor];
            CGRect frame = self.orderStatusLabel.frame;
            frame.origin.y = self.orderStatusLabel.frame.origin.y - 12;
            self.orderStatusLabel.frame = frame;
        } else if(status == 1) {
            self.stateBgImageView.hidden = NO;
            self.stateBgImageView.image = [UIImage imageNamed:@"order_state2.png"];
            
            self.orderStatusLabel.textColor = [UIColor whiteColor];
            CGRect frame = self.orderStatusLabel.frame;
            frame.origin.y = self.orderStatusLabel.frame.origin.y - 12;
            self.orderStatusLabel.frame = frame;
        } else {
            self.stateBgImageView.hidden = YES;
            self.orderStatusLabel.textColor = [UIColor darkGrayColor];
            self.orderStatusLabel.font = [UIFont boldSystemFontOfSize:20.0];
            self.orderStatusLabel.textAlignment = UITextAlignmentRight;
            CGRect frame = self.orderStatusLabel.frame;
            frame.origin.y = self.orderStatusLabel.frame.origin.y + 10;
            self.orderStatusLabel.frame = frame;
        }
        self.orderStatusLabel.text = [info objectForKey:@"statusDesc"];

        // 外卖送餐方式 0送餐上门, 1自取
        int addressHeight = 0;
        int deliveryType = [[info objectForKey:@"deliveryType"] intValue];
        if (1 == deliveryType) {
            self.deliveryTypeLabel.hidden = NO;
            self.addressLabel.hidden = YES;
            
            /*****************自取时坐标要调整到居中************************/
            CGFloat contentViewH = self.contentView.frame.size.height;
            CGRect frame = self.firstNameLabel.frame;
            frame.origin.y += 17;
            self.firstNameLabel.frame = frame;
            
            frame = self.sexLabel.frame;
            frame.origin.y += 17;
            self.sexLabel.frame = frame;
            
            frame = self.phoneLabel.frame;
            frame.origin.y = (contentViewH - self.phoneLabel.frame.size.height)/2;
            self.phoneLabel.frame = frame;
            
            frame = self.preOrderHourDateLabel.frame;
            frame.origin.y += 22;
            self.preOrderHourDateLabel.frame = frame;
            
            frame = self.inDateLabel.frame;
            frame.origin.y += 22;
            self.inDateLabel.frame = frame;
            
            frame = self.orderDateLabel.frame;
            frame.origin.y = (contentViewH - self.orderDateLabel.frame.size.height)/2;
            self.orderDateLabel.frame = frame;
        } else {
            self.deliveryTypeLabel.hidden = YES;
            self.addressLabel.hidden = NO;
            
            // 地址：
            self.addressLabel.text = [NSString stringWithFormat:@"%@：%@",
                                      kLoc(@"address"),
                                      [info objectForKey:@"address"]];
            addressHeight = [self.addressLabel adjustLabelHeight];
            
            UILabel *testAddressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 647, 30)];
            testAddressLabel.numberOfLines = 0;
            testAddressLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            testAddressLabel.text = [NSString stringWithFormat:@"%@：%@",
                                 kLoc(@"address"),
                                 [info objectForKey:@"address"]];
            addressHeight = [testAddressLabel adjustLabelHeight];            
        }
        
        CGRect frame = self.lineBgImageView.frame;
        frame.origin.y = self.frame.origin.y + self.frame.size.height - 1;
        self.lineBgImageView.frame = frame;
    }
    else
    {
        self.isCheckedImageview.hidden = YES;
        self.payMentImageView.hidden = YES;
        self.firstNameLabel.hidden = YES;
        self.phoneLabel.hidden = YES;
        self.addressLabel.hidden = YES;
        self.orderStatusLabel.hidden = YES;
        self.orderDateLabel.hidden = YES;
    }
}

#pragma mark memory

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===TakeoutTableViewCell,dealloc====");
#endif
}

@end
