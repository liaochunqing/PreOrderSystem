//
//  DtPreOrderDishTotalPriceTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>

@class QueueArrangDishDataClass;
@interface DtPreOrderDishTotalPriceTableViewCell : UITableViewCell

- (void)updateQueueLookDishTotalPriceCell:(CGFloat)totalPrice withFinalRemark:(NSString *)finalRemark;
- (CGFloat)getDtPreOrderDishTotalPriceTableViewCellHeight:(NSString *)finalRemark;

@end
