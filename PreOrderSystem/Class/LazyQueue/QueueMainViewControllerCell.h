//
//  QueueMainViewControllerCell.h
//  PreOrderSystem
//
//  Created by sWen on 13-3-7.
//
//

#import <UIKit/UIKit.h>
#import "ArrangTableViewCell.h"

@class QueueMainViewControllerCell;
@protocol QueueMainViewControllerCellDelegate <NSObject>

- (void)queueMainViewControllerCellTopHavedTap:(QueueMainViewControllerCell *)cell;
- (void)handleArrang:(QueueMainViewControllerCell *)cell wihtIndex:(int)index withCategoryName:(NSString *)categoryName;
- (void)whetherShowAllArrang:(int)index;

@end

@interface QueueMainViewControllerCell : UITableViewCell<ArrangTableViewCellDelegate>

@property (nonatomic, weak) id <QueueMainViewControllerCellDelegate>delegate;

- (void)updateViewAfterGetData:(NSDictionary *)dict withShowAllArrangFlag:(BOOL)flag;

@end
