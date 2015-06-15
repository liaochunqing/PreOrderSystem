//
//  OrderDetailTableViewCell.m
//  PreOrderSystem
//
//  Created by sWen on 12-12-10.
//
//

#import "PreorderOrderTableViewCell.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"

#define kLabelMaxWidth 40

@implementation PreorderOrderTableViewCell

@synthesize isCheckedImageview;
@synthesize firstNameLabel;
@synthesize sexLabel;
@synthesize phoneLabel;
@synthesize numberLabel;
@synthesize preOrderDateLabel;
@synthesize preOrderHourDateLabel;
@synthesize orderDateLabel;
@synthesize orderStatusLabel;
@synthesize stateBgImageView;

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

-(void)updateOrderMsgInfo:(NSDictionary *)info
{
    if (info!=nil)
    {
        self.isCheckedImageview.hidden = ([[info objectForKey:@"isChecked"] intValue])?YES:NO;
        self.isCallOrderImageview.hidden = ([[info objectForKey:@"byphone"] intValue])?NO:YES;
        //名称
        NSString *nameStr = [info objectForKey:@"guestName"];
        firstNameLabel.text = nameStr;
        
        if (1 == [nameStr length])
        {
            CGRect frame = sexLabel.frame;
            frame.origin.x = 44;
            sexLabel.frame = frame;
        }
        if ([nameStr length] > 2)
        {
            CGRect frame2 = firstNameLabel.frame;
            frame2.size.width = 80;
            firstNameLabel.frame = frame2;
            
            CGRect frame = sexLabel.frame;
            frame.origin.y = 42;
            frame.origin.x = firstNameLabel.frame.origin.x;
            sexLabel.frame = frame;
        }
        
        if (![NSString strIsEmpty:nameStr])
        {
            int sex = [[info objectForKey:@"guestSex"] intValue];
            switch (sex)
            {
                case 1:
                    sexLabel.text = kLoc(@"mister");
                    break;
                case 2:
                    sexLabel.text = kLoc(@"lady");
                    break;
                default:
                    sexLabel.text = @"";
                    break;
            }
        }
        else
        {
            self.sexLabel.text = @"";
        }
        
        //电话
        phoneLabel.text = [info objectForKey:@"guestPhone"];
        //人数
        int nop = [[info objectForKey:@"peopleNum"] intValue];
        if (nop>0)
        {
            numberLabel.text = [NSString stringWithFormat:@"%d人",nop];
        }
        else
        {
            numberLabel.text = @"";
        }
        
        //入座时间
        NSString *mealDateStr = [info objectForKey:@"diningTime"];
        NSDate *mealDate = [mealDateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
        preOrderDateLabel.text = [NSString dateToNSString:mealDate withFormat:@"MM-dd eee"];
        preOrderHourDateLabel.text = [NSString dateToNSString:mealDate withFormat:@"HH:mm"];
        
        //若状态为0，orderStatusLabel显示为蓝色，否则为深灰色
        int status = [[info objectForKey:@"status"] intValue];
        if (status==0)
        {
            stateBgImageView.hidden = NO;
            stateBgImageView.image = [UIImage imageNamed:@"order_state1.png"];
            
            orderStatusLabel.textColor = [UIColor whiteColor];
            orderStatusLabel.textAlignment = UITextAlignmentCenter;
            CGRect frame = orderStatusLabel.frame;
            frame.origin.y = 4;
            orderStatusLabel.frame = frame;
        }
        else if(status==1)
        {
            stateBgImageView.hidden = NO;
            stateBgImageView.image = [UIImage imageNamed:@"order_state2.png"];
            
            orderStatusLabel.textColor = [UIColor whiteColor];
            orderStatusLabel.textAlignment = UITextAlignmentCenter;
            CGRect frame = orderStatusLabel.frame;
            frame.origin.y = 4;
            orderStatusLabel.frame = frame;
        }
        else
        {
            stateBgImageView.hidden = YES;
            orderStatusLabel.textColor = [UIColor darkGrayColor];
            orderStatusLabel.font = [UIFont boldSystemFontOfSize:20.0];
            orderStatusLabel.textAlignment = UITextAlignmentRight;
            CGRect frame = orderStatusLabel.frame;
            frame.origin.y = 16;
            orderStatusLabel.frame = frame;
        }
        //订单状态
        orderStatusLabel.text = [info objectForKey:@"statusDesc"];
        
        //下单时间
        NSString *createdDateStr = [info objectForKey:@"orderTime"];
        NSDate *createdDate = [createdDateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
        orderDateLabel.text = [NSString dateToNSString:createdDate withFormat:@"MM-dd\nHH:mm"];
    }
    else
    {
        isCheckedImageview.hidden = YES;
        firstNameLabel.hidden = YES;
        phoneLabel.hidden = YES;
        numberLabel.hidden = YES;
        orderDateLabel.hidden = YES;
        orderStatusLabel.hidden = YES;
        orderDateLabel.hidden = YES;
    }
}
@end
