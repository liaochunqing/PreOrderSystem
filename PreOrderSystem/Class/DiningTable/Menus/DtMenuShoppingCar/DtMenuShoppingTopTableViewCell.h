//
//  DtMenuShoppingTopTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-1-3.
//
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "CustomPopoverTouchView.h"
#import "DtMenuCookbookStyleView.h"
#import "TakeoutShoppingCarSelectedView.h"  
#define kDtMenuPackageItemNameHeight 30
#define kDtMenuShoppingTopTableViewCellNormalHeight 136.0

@class DtMenuShoppingCarDataClass;
@class DtMenuShoppingTopTableViewCell;
@class CustomPopoverTouchView;
@protocol DtMenuShoppingTopTableViewCellDelegate <NSObject>

- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell withDishQuantityChange:(int)quantity;
- (void)dtMenuShoppingTopTableViewCellreloadCell:(DtMenuShoppingTopTableViewCell *)cell ;//foldOrspreadStatus:(int)foldOrspreadStatus;
/**
 *  在购物车中编辑了套餐任选/多选/必选项
 *
 *  @param cell          self
 *  @param newPackageArr 编辑后的新套餐数据.
 *  @param memberDic     被改变勾选状态的套餐子项.
 */
- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell didChangedPackage:(NSArray *)newPackageArr  andChangeMember:(NSDictionary *)memberDic;

/**
 *  更改了价格规格
 *
 *  @param cell       self
 *  @param priceClass 新的价格(style + price)
 *  @param indexPath  新价格样式的序号.第几个.
 */
- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell didChangePriceStyle:(DtMenuCookbookPriceDataClass *)priceClass andIndexPath:(NSIndexPath *)indexPath;

@end

@interface DtMenuShoppingTopTableViewCell : UITableViewCell<UITextFieldDelegate,CustomPopoverTouchViewDelegate,DtMenuCookbookStyleViewDelegate,PackageSelectedChangeDelegate>

@property (nonatomic, weak) id < DtMenuShoppingTopTableViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *dishNameScrollView;
@property (nonatomic, weak) IBOutlet UILabel *dishNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *quantityImageView;
@property (nonatomic, weak) IBOutlet UIButton *quantityReduceButton;
@property (nonatomic, weak) IBOutlet UITextField *quantityTextField;
@property (nonatomic, weak) IBOutlet UIButton *quantityAddButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UILabel *togetherLabel;
@property (nonatomic, weak) IBOutlet UILabel *partLabel;
@property (weak, nonatomic) IBOutlet UIButton *spreadOrfoldButton;



@property (nonatomic) int foldOrspreadStatus; //  0表示处于折叠状态, 1表示处于展开状态，
@property (nonatomic, assign) int sectionIndex;
@property (nonatomic, assign) int remarkTotalQuantity;
@property (nonatomic, strong) NSArray *priceArr;//所有价格&&样式.

/// 样式背景视图
@property(nonatomic, weak) IBOutlet UIImageView *styleBgImageView;
/// 样式下拉框视图
@property(nonatomic, weak) IBOutlet UIImageView *stylePullDownLogoImageView;
/// 样式名视图
@property(nonatomic, weak) IBOutlet UILabel *styleLabel;
/// 样式按钮
@property(nonatomic, weak) IBOutlet UIButton *styleButton;

//"优惠价:"标题.
@property (strong, nonatomic) IBOutlet UILabel *promotePriceTitleLabel;

//当前优惠价
@property (strong, nonatomic) IBOutlet UILabel *promotePrice;

//打包费标题
@property (strong, nonatomic) IBOutlet UILabel *packFeeTitleLabel;

//打包费
@property (strong, nonatomic) IBOutlet UILabel *packFeeLabel;

@property (strong, nonatomic) DtMenuShoppingCarDataClass *shoppingCarData;

- (void)updateDtMenuShoppingCarCell:(DtMenuShoppingCarDataClass *)dataClass;
- (IBAction)spreadOrfoldButtonClick:(UIButton *)sender;

@end
