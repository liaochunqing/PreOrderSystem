//
//  EditDiscountViewController.h
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "DiscountDataModel.h"
#import "PromoteCookBookGroupDataModel.h"
#import "EditDiscountTableViewCell.h"
#import "OriginalMenuTableViewCell.h"
@class EditDiscountViewController;
@protocol EditDiscountViewControllerProtocol <NSObject>
/**
 *  点击"取消"按钮直接返回的回调
 *
 *  @param ctl
 */
- (void)dismissEditDiscountViewController:(EditDiscountViewController *)ctl;

/**
 *  完成编辑后,点击"确定"按钮后的回调函数.
 *
 *  @param discountDataModel 准备提交的套餐数据.
 *  @param flag              YES:当前编辑的是已存在的套餐, NO:当前是添加新套餐.
 */
- (void)didFinishEditWithNewDiscountModel:(PromoteCookBookGroupDataModel *)newPromoteCookBookData isEditExistItem:(BOOL)flag;

@end

@interface EditDiscountViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,originalMenueTableViewCellDelegate,EditDiscountTableViewCellProtocol>

@property (nonatomic,weak) id <EditDiscountViewControllerProtocol> delegate;

//优惠套餐编号输入框
@property (weak, nonatomic) IBOutlet UITextField *discoutIdentifierTextField;

//优惠套餐名称输入框
@property (weak, nonatomic) IBOutlet UITextField *discoutNameTextField;

//菜系选择
@property (weak, nonatomic) IBOutlet UITextField *cuisineNameTextField;

//供选择的原始菜单(左)
@property (strong, nonatomic) IBOutlet UITableView *originalMenuTableView;

//优惠套餐中的菜单(右)
@property (strong, nonatomic) IBOutlet UITableView *discoutMenuTableView;

//显示菜系下拉列表按钮
@property (strong, nonatomic) IBOutlet UIButton *showCuisineListBtn;

//菜系下拉列表.
@property (strong, nonatomic) IBOutlet TableViewWithBlock *showCuisineTableView;

//退出按钮
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *promotionGroupSetLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *cookName;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

//确定按钮
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

//背景图
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;


//菜系&&菜品数据
@property (nonatomic,strong)NSMutableArray *cuisineDataArr;

//菜式优惠组合数据.
@property (nonatomic,strong)PromoteCookBookGroupDataModel *promoteCookbookGroupData;

//是否编辑已存在组合(非新增)
@property (nonatomic,assign) BOOL isEditExistItem;

//所有已存在的优惠组合item(用于新添加优惠组合时检测编号和优惠组合名是否重复)
@property (nonatomic,strong) NSArray *promoteCookbookGroupArr;


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
 *  编辑已存在套餐时的初始化方法
 *
 *  @param discountData 待编辑套餐
 *
 *  @return self
 */
- (id)initWithDiscountDataModel:(DiscountDataModel *)discountData;



@end
