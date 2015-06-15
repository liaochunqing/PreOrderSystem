//
//  TakeoutCookbookPackageViewController.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-17.
//
//

#import <UIKit/UIKit.h>
#import "DtMenuCookbookRemarkTableViewCell.h"
#import "DtMenuRemarkPickerViewController.h"
#import "DtMenuCookbookPackageTableViewCell.h"

@class DtMenuCookbookDataClass;

@protocol TakeoutCookbookPackageViewControllerDelegate;

/**
 * @brief   外卖套餐点菜视图控制器。
 *
 *
 */
@interface TakeoutCookbookPackageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, DtMenuCookbookRemarkTableViewCellDelegate,
DtMenuCookbookPackageTableViewCellDelegate, DtMenuRemarkPickerViewControllerDelegate>

/// 委托
@property(nonatomic, weak) id <TakeoutCookbookPackageViewControllerDelegate> delegate;
/// 背景视图
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
/// 价格标题视图
@property(nonatomic, weak) IBOutlet UILabel *priceTitleLabel;
/// 价格视图
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;
/// 菜系名称视图
@property(nonatomic, weak) IBOutlet UILabel *dishNameLabel;
/// 菜系名称滚动视图
@property(nonatomic, weak) IBOutlet UIScrollView *dishNameScrollView;
/// 数量背景视图
@property(nonatomic, weak) IBOutlet UIImageView *quantityBgImageView;
/// 数量文本框视图
@property(nonatomic, weak) IBOutlet UITextField *quantityTextField;
/// 数量减按钮
@property(nonatomic, weak) IBOutlet UIButton *quantityReduceButton;
/// 数量加按钮
@property(nonatomic, weak) IBOutlet UIButton *quantityAddButton;
/// 套餐详情列表视图
@property(nonatomic, weak) IBOutlet UITableView *cookbookPackageTableView;
/// 添加备注按钮
@property(nonatomic, weak) IBOutlet UIButton *remarkButton;
/// 总价视图
@property(nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
/// 提交按钮背景视图
@property(nonatomic, weak) IBOutlet UIImageView *handleBtnBgImageView;
/// 标题视图
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
/// 取消（返回）按钮
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
/// 确定按钮
@property(nonatomic, weak) IBOutlet UIButton *trueButton;
/// 菜系信息
@property(nonatomic, strong) DtMenuCookbookDataClass *cookbookDataClass;
/// 所有备注列表
@property(nonatomic, strong) NSArray *cuisineRemarkArray;

//优惠价
@property (strong, nonatomic) IBOutlet UILabel *promotePriceLabel;

//装载套餐tableView和添加备注按钮...的一个子view,为了方便在有打包费或优惠价时将下半部分整体往下挪.
@property (strong, nonatomic) IBOutlet UIView *LastHalfView;

//打包费
@property (strong, nonatomic) IBOutlet UILabel *packFeeLabel;



//该菜系是否有备注可选
@property (nonatomic, assign) BOOL isNoRemark;



/**
 * @brief   尝试关闭视图。
 *
 */
- (void)tryDismissView;

@end

/**
 * @brief   套餐点菜视图委托。
 *
 */
@protocol TakeoutCookbookPackageViewControllerDelegate <NSObject>

/**
 * @brief   关闭套餐点菜视图回调。
 *
 */
- (void)takeoutCookbookPackageViewHavedDismiss;

/**
 *  完成编辑后,通知上层更新购物车
 *
 *  @param ctl             self
 *  @param packageDishData 编辑后的套餐数据
 */
-(void)takeoutCookbookPackageViewController:(TakeoutCookbookPackageViewController *)ctl didSavePackageDish:(NSDictionary *)packageDishData;

@end

