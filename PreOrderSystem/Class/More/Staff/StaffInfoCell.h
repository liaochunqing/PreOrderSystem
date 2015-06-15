//
//  StaffInfoCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-7.
//
//

#import <UIKit/UIKit.h>

#define kStaffInfoCellWidth 341

@class StaffManagementStaffInfoDataClass;
@protocol StaffInfoCellDelegate;

@interface StaffInfoCell : UIView

@property (nonatomic, weak) id <StaffInfoCellDelegate> delegate;

- (void)updateStaffInfoCell:(StaffManagementStaffInfoDataClass *)staffInfo;

@end

@protocol StaffInfoCellDelegate <NSObject>

- (void)staffInfoCell:(StaffInfoCell *)cell withEidtData:(NSInteger)index;
- (void)staffInfoCell:(StaffInfoCell *)cell withDeleteStaff:(NSString *)staffIdStr;

@end
