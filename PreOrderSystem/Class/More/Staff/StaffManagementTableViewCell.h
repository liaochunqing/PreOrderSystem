//
//  StaffManagementTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-7.
//
//

#import <UIKit/UIKit.h>

#define kStaffManagementCellHeight 180
#define kStaffManagementCellWidth 745
#define kStaffManagementCellHaveTwoSubCell 2
#define kStaffManagementCellFirstSubCellIndex 0
#define kStaffManagementCellSecondSubCellIndex 1

@class StaffManagementStaffInfoDataClass;
@protocol StaffManagementTableViewCellDelegate;
@interface StaffManagementTableViewCell : UITableViewCell

@property (nonatomic, weak) id <StaffManagementTableViewCellDelegate>delegate;

- (void)updateStaffManagementCell:(StaffManagementStaffInfoDataClass *)firstStaffInfo withSecondStaffData:(StaffManagementStaffInfoDataClass *)secondStaffInfo;

@end

@protocol StaffManagementTableViewCellDelegate <NSObject>

- (void)staffManagementTableViewCell:(StaffManagementTableViewCell *)cell withEidtData:(NSInteger)index;
- (void)staffManagementTableViewCell:(StaffManagementTableViewCell *)cell withDeleteStaff:(NSString *)staffId;

@end