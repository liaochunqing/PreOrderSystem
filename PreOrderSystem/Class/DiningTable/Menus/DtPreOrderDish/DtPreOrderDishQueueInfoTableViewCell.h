//
//  DtPreOrderDishQueueInfoTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-21.
//
//

#import <UIKit/UIKit.h>

#define kDtPreOrderDishQueueInfoCellReuseIdentifier @"dtPreOrderDishQueueInfoCellIdentifier"

@class DtQueueDataClass;
@class DtPreOrderDishQueueInfoTableViewCell;
@protocol DtPreOrderDishQueueInfoTableViewCellDelegate <NSObject>

- (void)dtPreOrderDishQueueInfoTableViewCell:(DtPreOrderDishQueueInfoTableViewCell *)cell wihtNewDtQueueData:(DtQueueDataClass *)queueClass;
- (void)dtPreOrderDishQueueInfoTableViewCell:(DtPreOrderDishQueueInfoTableViewCell *)cell wihtDeleteIndex:(NSInteger )index;

@end

/**
 * 预点菜入台,排队入座的信息
 */
@interface DtPreOrderDishQueueInfoTableViewCell : UITableViewCell

@property (nonatomic, weak) id <DtPreOrderDishQueueInfoTableViewCellDelegate> delegate;

- (void)updateDtPreOrderDishQueueInfoCell:(DtQueueDataClass *)queueClass;

@end
