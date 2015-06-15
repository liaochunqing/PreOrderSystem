//
//  MemberLookDishTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>


@class MemberDishDataClass;
@interface MemberLookDishTableViewCell : UITableViewCell

- (void)updateMemberLookDishCell:(MemberDishDataClass *)dishClass;
- (CGFloat)getMemberLookDishTableViewCellHeight:(MemberDishDataClass *)dishClass;

@end
