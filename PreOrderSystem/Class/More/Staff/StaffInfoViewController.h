//
//  StaffInfoViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-7.
//
//

#import <UIKit/UIKit.h>

#define kStaffInfoViewControllerOrigin (CGPointMake(20, kSystemVersionIsIOS7?120:100))

@class StaffManagementStaffInfoDataClass;
@class StaffInfoViewController;
@protocol StaffInfoViewControllerDelegate <NSObject>

- (void)staffInfoViewController:(StaffInfoViewController*)ctrl didDismissView:(NSDictionary *)lastestStaffListData;

@end

/**
 * @brief   添加员工、员工资料编辑视图控制器。
 *
 *
 */
@interface StaffInfoViewController : UIViewController

@property (nonatomic, weak) id <StaffInfoViewControllerDelegate> delegate;
@property (nonatomic, strong) StaffManagementStaffInfoDataClass *staffInfo;
@property (nonatomic, strong) NSMutableArray *postListArray;
@property (nonatomic, assign) BOOL isAddNewStaff;
@property (nonatomic, assign) BOOL isTakePhoto;/*是否是在拍照*/

@end
