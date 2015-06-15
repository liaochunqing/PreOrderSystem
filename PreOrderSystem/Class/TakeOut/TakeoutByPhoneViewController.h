//
//  TakeoutByPhoneViewController.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-17.
//
//

#import <UIKit/UIKit.h>
#import "DtMenuListTableViewCell.h"
#import "JsonPicker.h"
#import "EGORefreshTableHeaderView.h"
#import "TakeoutCookbookViewController.h"
#import "TakeoutCookbookPackageViewController.h"
#import "TakeoutShoppingCarViewController.h"
#import "DiningTableCommon.h"

//JustTest:
#import "DishSelectView.h"
//endTest

@protocol TakeoutByPhoneViewControllerDelegate;

/**
 * @brief   电话外卖视图控制器。
 *
 */
@interface TakeoutByPhoneViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
DtMenuListTableViewCellDelegate, JsonPickerDelegate, EGORefreshTableHeaderDelegate,
TakeoutCookbookViewControllerDelegate, TakeoutCookbookPackageViewControllerDelegate,
TakeoutShoppingCarViewControllerDelegate,DishSelectViewDelegate>

/// 委托
@property(nonatomic, weak) id <TakeoutByPhoneViewControllerDelegate> delegate;
/// 用户资料按钮
@property(nonatomic, weak) IBOutlet UIButton *userInfoButton;
/// 购物车按钮
@property(nonatomic, weak) IBOutlet UIButton *shoppingCarButton;
/// 返回按钮
@property(nonatomic, weak) IBOutlet UIButton *backButton;
/// 背景视图
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
/// 菜系滚动容器
@property(nonatomic, weak) IBOutlet UIScrollView *cuisineScrollView;
/// 菜式列表视图
@property(nonatomic, weak) IBOutlet UITableView *menuTableView;

///菜式的备注数组
@property (nonatomic,strong) NSArray *cuisineRemarkArray;

///电话外卖,默认选项(YES:自取 NO:送餐)
@property (nonatomic,assign) BOOL phoneOrderTypeDefault;

//电话外卖输入资料的顺序,0：点菜后台填写用户信息,1：填写用户信息后点菜
@property (nonatomic,assign) BOOL phoneOrderInputTypeDefault;



/**
 * @brief   尝试关闭。
 *
 */
- (void)tryDismissView;

@end

/**
 * @brief   电话外卖视图控制器委托。
 *
 *
 */
@protocol TakeoutByPhoneViewControllerDelegate <NSObject>

/**
 * @brief   电话外卖视图关闭回调。
 *
 * @param   viewController  电话外卖视图控制器。
 * @param   isDataChanged   是否有提交数据，用于更新主页。
 *
 */
- (void)takeoutByPhoneViewController:(TakeoutByPhoneViewController *)viewController
              dismissWithDataChanged:(BOOL)isDataChanged;

@end

