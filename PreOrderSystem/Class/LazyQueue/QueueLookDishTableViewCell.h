//
//  QueueLookDishTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>


@class QueueArrangDishDataClass;
@interface QueueLookDishTableViewCell : UITableViewCell

- (void)updateQueueLookDishCell:(QueueArrangDishDataClass *)dishClass;
- (CGFloat)getQueueLookDishTableViewCellHeight:(QueueArrangDishDataClass *)dishClass;

@end
