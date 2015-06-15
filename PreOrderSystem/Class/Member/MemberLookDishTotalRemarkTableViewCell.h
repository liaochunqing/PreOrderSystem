//
//  MemberLookDishTotalRemarkTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>

#define kMemberLookDishTotalRemarkTableViewCellReuseIdentifier @"totalRemarkTableViewCellIdentifier"

@interface MemberLookDishTotalRemarkTableViewCell : UITableViewCell

- (void)updateMemberLookDishTotalRemarkCell:(NSString *)totalRemark;
- (CGFloat)getMemberLookDishTotalRemarkTableViewCellHeight:(NSString *)finalRemark;

@end
