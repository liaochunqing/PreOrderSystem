//
//  OrderDetailTableViewCell.h
//  PreOrderSystem
//
//  Created by sWen on 12-12-10.
//
//预定页面的cell

#import <UIKit/UIKit.h>

#define kPreOrderTableViewCellReuseIdentifier @"preOrderTableViewCellIdentifier"

@interface PreorderOrderTableViewCell : UITableViewCell
{
    __weak UIImageView *isCheckedImageview;
    __weak UILabel *firstNameLabel;
    __weak UILabel *sexLabel;
    __weak UILabel *phoneLabel;
    __weak UILabel *numberLabel;
    __weak UILabel *preOrderHourDateLabel;
    __weak UILabel *orderDateLabel;
    __weak UILabel *orderStatusLabel;
    __weak UILabel *preOrderDateLabel;
    __weak UIImageView *stateBgImageView;
    
    NSDictionary *orderMsgInfo;
}

@property (nonatomic, weak) IBOutlet UIImageView *isCheckedImageview;
@property (nonatomic, weak) IBOutlet UIImageView *isCallOrderImageview;
@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sexLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *preOrderDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *preOrderHourDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderDateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *stateBgImageView;

- (void)updateOrderMsgInfo:(NSDictionary *)info;

@end
