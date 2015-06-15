//
//  TakeoutShoppingCarViewController.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-18.
//
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"
#import "DtMenuShoppingTopTableViewCell.h"
#import "DtMenuShoppingBottomTableViewCell.h"
#import "DtMenuCookbookRemarkTableViewCell.h"
#import "DtMenuRemarkPickerViewController.h"
#import "DiningTableCommon.h"

@class DtMenuShoppingCarListDataClass;

@protocol TakeoutShoppingCarViewControllerDelegate;

/**
 * @brief   电话外卖购物车视图控制器。
 *
 */
@interface TakeoutShoppingCarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
JsonPickerDelegate, DtMenuShoppingTopTableViewCellDelegate, DtMenuShoppingBottomTableViewCellDelegate,
DtMenuCookbookRemarkTableViewCellDelegate, DtMenuRemarkPickerViewControllerDelegate>

/// 委托
@property(nonatomic, weak) id <TakeoutShoppingCarViewControllerDelegate> delegate;
/// 购物车清单
@property(nonatomic, strong) DtMenuShoppingCarListDataClass *shoppingCarListDataClass;
/// 是否正在等待资料录入
@property (nonatomic) BOOL isWaitingForContinue;

/**
 * @brief   尝试关闭视图。
 *
 */
- (void)tryDismissView;


/**
 *   jhh_test 选中了新菜后,刷新购物车.
 */
- (void)reload;

@end

/**
 * @brief   电话外卖购物车委托。
 *
 *
 */
@protocol TakeoutShoppingCarViewControllerDelegate <NSObject>

/**
 * @brief   关闭电话外卖购物车视图回调。
 *
 * @param   viewController  电话外卖视图控制器。
 *
 */
- (void)takeoutShoppingCarViewHadDismiss:(TakeoutShoppingCarViewController *)viewController;

/**
 * @brief   电话外卖购物车视图提交成功回调。
 *
 * @param   viewController  电话外卖视图控制器。
 *
 */
- (void)takeoutShoppingCarViewSubmitted:(TakeoutShoppingCarViewController *)viewController;

/**
 * @brief   用户资料输入回调。
 *
 * @param   viewController  电话外卖视图控制器。
 *
 */
- (void)takeoutShoppingCarViewMustInputUserInfo:(TakeoutShoppingCarViewController *)viewController;

/**
 *  优惠价格有变动,提交失败
 *
 *  @param superDataClass 提交失败时,服务器返回的新菜品数据
 */
- (void)takeoutShoppingCarViewSubmittedFailWithNewCookBookData:(SuperDataClass *)superDataClass;

@end
