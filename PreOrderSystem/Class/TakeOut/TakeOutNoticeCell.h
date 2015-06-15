//
//  TakeOutNoticeCell.h
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-10-14.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTakeOutNoticeCellTableViewCellReuseIdentifier @"takeOutNoticeTableViewCellIdentifier"

@class TakeOutNoticeCell;
@protocol TakeOutNoticeCellDelegate <NSObject>

- (void)beginEditingTakeOutNoticeCell:(TakeOutNoticeCell *)cell;
- (void)endEditingTakeOutNoticeCell:(TakeOutNoticeCell *)cell;
- (void)deleteTakeOutNoticeCell:(int)index;

@end

@interface TakeOutNoticeCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id <TakeOutNoticeCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *noticeBgView;
@property (nonatomic, weak) IBOutlet UITextField *noticeTextField;
@property (nonatomic, weak) IBOutlet UILabel *serialNumberLabel;
@property (nonatomic, weak) IBOutlet UIButton *deleteBtn;

- (void)reloadDataAfterLoadView:(NSString *)noticeStr;

@end
