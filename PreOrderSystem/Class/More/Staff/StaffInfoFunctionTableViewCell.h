//
//  StaffInfoFunctionTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-8.
//
//

#import <UIKit/UIKit.h>

@class StaffManagementAuthDataClass;
@class StaffInfoFunctionTableViewCell;
@protocol StaffInfoFunctionTableViewCellDelegate <NSObject>

- (void)staffInfoFunctionTableViewCell:(StaffInfoFunctionTableViewCell *)cell withAuthStateHavedChange:(StaffManagementAuthDataClass *)authInfo;

@end

@interface StaffInfoFunctionTableViewCell : UITableViewCell

@property (nonatomic, weak) id <StaffInfoFunctionTableViewCellDelegate> delegate;
- (void)updateStaffInfoFunctionCell:(StaffManagementAuthDataClass *)authInfo;
- (CGFloat)getFunctionCellHeight:(StaffManagementAuthDataClass *)authInfo;

@end
