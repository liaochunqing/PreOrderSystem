//
//  TakeOutTableViewCell.h
//  PreOrderSystem
//
//  Created by sWen on 12-12-11.
//
//外卖页面的cell

#import <UIKit/UIKit.h>

@interface TakeOutTableViewCell : UITableViewCell
{
    NSDictionary *orderMsgInfo;
}
@property (weak, nonatomic) IBOutlet UILabel *inDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sexLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *preOrderHourDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *deliveryTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIImageView *isCheckedImageview;
@property (nonatomic, weak) IBOutlet UIImageView *payMentImageView;
@property (nonatomic, weak) IBOutlet UIImageView *isRemindersImageView;
@property (nonatomic, weak) IBOutlet UIImageView *stateBgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *lineBgImageView;

-(void)updateOrderMsgInfo:(NSDictionary *)info;

@end
