//
//  OrderNoticeCell.h
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-10-14.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPreOrderNoticeCellTableViewCellReuseIdentifier @"preOrderNoticeTableViewCellIdentifier"

@class OrderNoticeCell;
@protocol OrderNoticeCellDelegate <NSObject>

- (void)beginEditingOrderNoticeCell:(OrderNoticeCell *)cell;
- (void)endEditingOrderNoticeCell:(OrderNoticeCell *)cell;
- (void)deleteOrderNoticeCell:(int)index;

@end

@interface OrderNoticeCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id <OrderNoticeCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *noticeBgView;
@property (nonatomic, weak) IBOutlet UITextField *noticeTextField;
@property (nonatomic, weak) IBOutlet UILabel *serialNumberLabel;
@property (nonatomic, weak) IBOutlet UIButton *deleteBtn;

- (void)reloadDataAfterLoadView:(NSString *)noticeStr;

@end
