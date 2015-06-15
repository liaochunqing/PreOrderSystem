//
//  DtMenuShoppingBottomTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-1-3.
//
//

#import <UIKit/UIKit.h>

@class DtMenuShoppingBottomTableViewCell;
@protocol DtMenuShoppingBottomTableViewCellDelegate <NSObject>

- (void)dtMenuShoppingBottomTableViewCell:(DtMenuShoppingBottomTableViewCell *)cell;

@end

@interface DtMenuShoppingBottomTableViewCell : UITableViewCell

@property(nonatomic, weak) id < DtMenuShoppingBottomTableViewCellDelegate> delegate;
@property (nonatomic, assign) int dishQuantity;
@property (nonatomic, assign) int remarkQuantity;
@property(nonatomic, assign) int sectionIndex;

- (void)updateDtMenuShoppingBottomCell;

@end
