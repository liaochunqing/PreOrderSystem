//
//  TakeoutUserInfoViewController.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-19.
//
//

#import <UIKit/UIKit.h>

@class CustomTimePicker;
@class OrderByPhoneViewController;

@protocol TakeoutUserInfoViewControllerDelegate;

/**
 * @brief   电话外卖用户资料输入视图控制器。
 *
 */
@interface TakeoutUserInfoViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate>

/// 委托
@property (nonatomic, weak) id <TakeoutUserInfoViewControllerDelegate> delegate;

/// 滚动容器视图
@property (nonatomic, weak) IBOutlet UIScrollView *basicScrollview;
/// 子滚动视图
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

/// 标题视图
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
/// 称呼标题视图
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
/// 称呼输入框
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
/// 电话号码标题视图
@property (nonatomic, weak) IBOutlet UILabel *phoneNumberLabel;
/// 大陆按钮
@property (nonatomic, weak) IBOutlet UIButton *daluButton;
/// 香港按钮
@property (nonatomic, weak) IBOutlet UIButton *hongkongButton;
/// 电话号码区号视图
@property (nonatomic, weak) IBOutlet UILabel *phoneNumberPrefixLabel;
/// 电话号码输入框
@property (nonatomic, weak) IBOutlet UITextField *phoneNumberTextField;
/// 外卖按钮
@property (nonatomic, weak) IBOutlet UIButton *takeoutButton;
/// 自取按钮
@property (nonatomic, weak) IBOutlet UIButton *takeinButton;
/// 地址视图
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
/// 地址输入框
@property (nonatomic, weak) IBOutlet UITextField *addressTextField;
/// 日期标题视图
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
/// 日期输入框
@property (nonatomic, weak) IBOutlet UITextField *dateTextField;
/// 取消按钮
@property (nonatomic, weak) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *takeoutTypeLabel;

/// 外卖时间选择视图
@property (nonatomic, strong) UIDatePicker *datetimePicker;

///外卖方式,默认选项(YES:自取 NO:送餐)
@property (nonatomic,assign) BOOL phoneOrderTypeDefault;

@end

/**
 * @brief   用户资料输入委托。
 *
 */
@protocol TakeoutUserInfoViewControllerDelegate <NSObject>

/**
 * @brief   关闭用户资料视图回调。
 *
 * @param   viewController  用户资料输入视图控制器。
 *
 */
- (void)takeoutUserInfoViewControllerDidDismiss:(TakeoutUserInfoViewController *)viewController;

@end
