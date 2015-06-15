//
//  DtPreOrderDishTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>


@class QueueArrangDishDataClass;
@interface DtPreOrderDishTableViewCell : UITableViewCell

- (void)updateQueueLookDishCell:(QueueArrangDishDataClass *)dishClass;
- (CGFloat)getDtPreOrderDishTableViewCellHeight:(QueueArrangDishDataClass *)dishClass;

@end
