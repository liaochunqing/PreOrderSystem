//
//  QueueLookDishTotalRemarkTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>

#define kQueueLookDishTotalRemarkTableViewCellReuseIdentifier @"totalRemarkTableViewCellIdentifier"

@class QueueArrangDishDataClass;
@interface QueueLookDishTotalRemarkTableViewCell : UITableViewCell

- (void)updateQueueLookDishTotalRemarkCell:(NSString *)totalRemark;
- (CGFloat)getQueueLookDishTotalRemarkTableViewCellHeight:(NSString *)finalRemark;

@end
