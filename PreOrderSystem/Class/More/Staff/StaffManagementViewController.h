//
//  StaffManagementViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-6.
//
//

#import <UIKit/UIKit.h>

#define kStaffManagementViewControllerOrigin (CGPointMake(50, kSystemVersionIsIOS7?120:100))
@class MoreViewController;
@interface StaffManagementViewController : UIViewController
@property (nonatomic, assign) MoreViewController *fatherVC;
@end
