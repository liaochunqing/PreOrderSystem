//
//  CouponUseHeadTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-24.
//
//

#import <UIKit/UIKit.h>

/**
 * 优惠劵cell
 */

#define kCouponUseHeadTableViewCellReuseIdentifier @"couponUseHeadTableViewCellIdentifier"

@class MemberCurrentSortDataClass;
@class CouponUseHeadTableViewCell;
@protocol CouponUseHeadTableViewCellDelegate <NSObject>

- (void)couponUseHeadTableViewCell:(CouponUseHeadTableViewCell *)cell withSortHavedChanged:(BOOL)openFlag;

@end

@interface CouponUseHeadTableViewCell : UITableViewCell

@property (nonatomic, weak) id <CouponUseHeadTableViewCellDelegate> delegate;

- (void)updateCouponUserHeadCell:(MemberCurrentSortDataClass *)sortClass;

@end
