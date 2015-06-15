//
//  TakeoutCookbookViewController.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-17.
//
//

#import <UIKit/UIKit.h>
#import "DtMenuCookbookRemarkTableViewCell.h"
#import "DtMenuCookbookStyleView.h"
#import "JsonPicker.h"
#import "DtMenuRemarkPickerViewController.h"

@class DtMenuCookbookDataClass;

@protocol TakeoutCookbookViewControllerDelegate;

/**
 * @brief   外卖普通点菜视图控制器。
 *
 *
 */
@interface TakeoutCookbookViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DtMenuCookbookRemarkTableViewCellDelegate, DtMenuCookbookStyleViewDelegate, DtMenuRemarkPickerViewControllerDelegate>

/// 委托
@property(nonatomic, weak) id <TakeoutCookbookViewControllerDelegate> delegate;
/// 背景视图
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
/// 价格标题视图
@property(nonatomic, weak) IBOutlet UILabel *priceTitleLabel;
/// 价格视图
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;
/// 菜名视图
@property(nonatomic, weak) IBOutlet UILabel *dishNameLabel;
/// 菜名容器（滚动菜名）
@property(nonatomic, weak) IBOutlet UIScrollView *dishNameScrollView;
/// 样式背景视图
@property(nonatomic, weak) IBOutlet UIImageView *styleBgImageView;
/// 样式下拉框视图
@property(nonatomic, weak) IBOutlet UIImageView *stylePullDownLogoImageView;
/// 样式名视图
@property(nonatomic, weak) IBOutlet UILabel *styleLabel;
/// 样式按钮
@property(nonatomic, weak) IBOutlet UIButton *styleButton;
/// 数量背景视图
@property(nonatomic, weak) IBOutlet UIImageView *quantityBgImageView;
/// 数量文本框
@property(nonatomic, weak) IBOutlet UITextField *quantityTextField;
/// 数量减按钮
@property(nonatomic, weak) IBOutlet UIButton *quantityReduceButton;
/// 数量加按钮
@property(nonatomic, weak) IBOutlet UIButton *quantityAddButton;
/// 备注清单视图
@property(nonatomic, weak) IBOutlet UITableView *cookbookRemarkTableView;
/// 添加备注按钮
@property(nonatomic, weak) IBOutlet UIButton *remarkButton;
/// 总价视图
@property(nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
/// 确定按钮背景视图
@property(nonatomic, weak) IBOutlet UIImageView *handleBtnBgImageView;
/// 标题视图
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
/// 取消（返回）按钮
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
/// 确定按钮
@property(nonatomic, weak) IBOutlet UIButton *trueButton;
/// 菜系信息
@property(nonatomic, strong) DtMenuCookbookDataClass *cookbookDataClass;
/// 所有备注清单
@property(nonatomic, strong) NSArray *cuisineRemarkArray;

/**
 * @brief   尝试关闭视图。
 *
 */
- (void)tryDismissView;

@end

/**
 * @brief   点菜委托。
 *
 *
 */
@protocol TakeoutCookbookViewControllerDelegate <NSObject>

/**
 * @brief   视图关闭回调。
 *
 *
 */
- (void)takeoutCookbookViewHavedDismiss;

@end

