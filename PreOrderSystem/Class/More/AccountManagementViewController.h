//
//  AccountManagementViewController.h
//  PreOrderSystem
//
//  Created by sWen on 12-10-24.
//
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"
@class MoreViewController;

#define kAccountManagementViewControllerOrigin (CGPointMake(20, kSystemVersionIsIOS7?120:100))

@interface AccountManagementViewController : UIViewController

@property (nonatomic, assign) BOOL editAuthorityFlag;
@property (nonatomic, assign) MoreViewController *fatherVC;
@end
