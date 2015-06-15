//
//  CouponUseTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-24.
//
//

#import <UIKit/UIKit.h>

/**
 * 优惠劵使用cell
 */

#define kCouponUseTableViewCellReuseIdentifier @"couponUseTableViewCellIdentifier"

@class MemberUseCountDataClass;
@class CouponUseTableViewCell;
@protocol CouponUseTableViewCellDelegate <NSObject>

- (void)couponUseTableViewCell:(CouponUseTableViewCell *)cell withDetailBtnClicked:(NSInteger)cellIndex;

@end

@interface CouponUseTableViewCell : UITableViewCell

@property (nonatomic, weak) id <CouponUseTableViewCellDelegate> delegate;

- (void)updateCouponUseCell:(MemberUseCountDataClass *)useCountClass;

@end
