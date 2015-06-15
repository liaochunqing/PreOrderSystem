//
//  CouponTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-24.
//
//

#import <UIKit/UIKit.h>

/**
 * 优惠劵cell
 */

#define kCouponTableViewCellReuseIdentifier @"couponTableViewCellIdentifier"

@class MemberTypeCountDataClass;
@interface CouponTableViewCell : UITableViewCell

- (void)updateCouponCell:(MemberTypeCountDataClass *)typeCountClass;

@end
