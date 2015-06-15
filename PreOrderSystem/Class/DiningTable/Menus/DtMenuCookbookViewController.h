//
//  DtMenuCookbookViewController.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import <UIKit/UIKit.h>
#import "DtMenuCookbookRemarkTableViewCell.h"
#import "DtMenuCookbookStyleView.h"
#import "JsonPicker.h"
#import "DtMenuRemarkPickerViewController.h"

@class DtMenuCookbookDataClass;
@class DtMenuCookbookViewController;
@protocol DtMenuCookbookViewControllerDelegate <NSObject>

- (void)DtMenuCookbookViewHavedDismiss;

@end

@interface DtMenuCookbookViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DtMenuCookbookRemarkTableViewCellDelegate, DtMenuCookbookStyleViewDelegate, JsonPickerDelegate, DtMenuRemarkPickerViewControllerDelegate>

@property(nonatomic, weak) id < DtMenuCookbookViewControllerDelegate> delegate;
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UILabel *priceTitleLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;
@property(nonatomic, weak) IBOutlet UILabel *dishNameLabel;
@property(nonatomic, weak) IBOutlet UIScrollView *dishNameScrollView;
@property(nonatomic, weak) IBOutlet UIImageView *styleBgImageView;
@property(nonatomic, weak) IBOutlet UIImageView *stylePullDownLogoImageView;
@property(nonatomic, weak) IBOutlet UILabel *styleLabel;
@property(nonatomic, weak) IBOutlet UIButton *styleButton;
@property(nonatomic, weak) IBOutlet UIImageView *quantityBgImageView;
@property(nonatomic, weak) IBOutlet UITextField *quantityTextField;
@property(nonatomic, weak) IBOutlet UIButton *quantityReduceButton;
@property(nonatomic, weak) IBOutlet UIButton *quantityAddButton;
@property(nonatomic, weak) IBOutlet UITableView *cookbookRemarkTableView;
@property(nonatomic, weak) IBOutlet UIButton *remarkButton;
@property(nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
@property(nonatomic, weak) IBOutlet UIImageView *handleBtnBgImageView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
@property(nonatomic, weak) IBOutlet UIButton *trueButton;
@property(nonatomic, strong) DtMenuCookbookDataClass *cookbookDataClass;
@property(nonatomic, strong) NSArray *cuisineRemarkArray;
@property(nonatomic, assign) int housingId;



//当前优惠价
@property (strong, nonatomic) IBOutlet UILabel *promotePrice;

/**
 * @brief   尝试关闭视图。
 *
 */
- (void)tryDismissView;

@end
