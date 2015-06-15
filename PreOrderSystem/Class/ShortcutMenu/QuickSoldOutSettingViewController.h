//
//  QuickSoldOutSettingViewController.h
//  PreOrderSystem
//
//  Created by mac on 14-7-19.
//
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "OriginalMenuTableViewCell.h"
#import "QuickSoldOutSettingTableViewCell.h"

@class QuickSoldOutSettingViewController;
@protocol QuickSoldOutSettingViewControllerProtocol <NSObject>
/**
 *  点击"取消"按钮直接返回的回调
 *
 *  @param ctl
 */
- (void)dismissEditDiscountViewController:(QuickSoldOutSettingViewController *)ctl;

/**
 *  完成编辑后,点击"确定"按钮后的回调函数.
 *
 *  @param discountDataModel 准备提交的套餐数据.
 *  @param flag              YES:当前编辑的是已存在的套餐, NO:当前是添加新套餐.
 */
//- (void)didFinishEditWithNewDiscountModel:(DiscountDataModel *)discountDataModel andIsExistingDiscount:(BOOL)flag;

@end

@interface QuickSoldOutSettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,originalMenueTableViewCellDelegate,QuickSoldOutSettingTableViewCellProtocol>

@property (nonatomic,weak)id <QuickSoldOutSettingViewControllerProtocol> delegate;

//菜系选择
@property (weak, nonatomic) IBOutlet UITextField *cuisineNameTextField;

//供选择的原始菜单(左)
@property (strong, nonatomic) IBOutlet UITableView *originalMenuTableView;

//优惠套餐中的菜单(右)
@property (strong, nonatomic) IBOutlet UITableView *soldOutTableView;

//显示菜系下拉列表按钮
@property (strong, nonatomic) IBOutlet UIButton *showCuisineListBtn;

//菜系下拉列表.
@property (strong, nonatomic) IBOutlet TableViewWithBlock *showCuisineTableView;

//退出按钮
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;

//确定按钮
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

//背景图
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

//沽清快捷键的key（不是tag),提交数据时要用到
@property (nonatomic,strong)NSString *hotkeyKey;



//标记当前是编辑已存在套餐还是新添加套餐 (YES:编辑已存在套餐,NO:新添加套餐)
@property (nonatomic,assign) BOOL isExistingDiscount;

//菜系&&菜品数据
@property (nonatomic,strong)NSMutableArray *cuisineDataArr;




/**
 *  按下确定按钮
 *
 *  @param sender sureBtn
 */
- (IBAction)sureBtnPress:(id)sender;

/**
 *  按下取消按钮
 *
 *  @param sender cancelBtn
 */
- (IBAction)cancelBtnPress:(id)sender;

/**
 *  按下显示菜系按钮
 */
- (IBAction)showCuisineList:(id)sender;


@end
