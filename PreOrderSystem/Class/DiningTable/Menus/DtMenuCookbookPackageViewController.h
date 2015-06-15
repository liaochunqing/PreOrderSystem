//
//  DtMenuCookbookPackageViewController.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import <UIKit/UIKit.h>
#import "DtMenuCookbookRemarkTableViewCell.h"
#import "JsonPicker.h"
#import "DtMenuRemarkPickerViewController.h"
#import "DtMenuCookbookPackageTableViewCell.h"

@class DtMenuCookbookDataClass;
@class DtMenuCookbookPackageViewController;
@protocol DtMenuCookbookPackageViewControllerDelegate <NSObject>

- (void)DtMenuCookbookPackageViewHavedDismiss;

@end

@interface DtMenuCookbookPackageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DtMenuCookbookRemarkTableViewCellDelegate, DtMenuCookbookPackageTableViewCellDelegate, JsonPickerDelegate, DtMenuRemarkPickerViewControllerDelegate>

@property(nonatomic, weak) id < DtMenuCookbookPackageViewControllerDelegate> delegate;
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UILabel *priceTitleLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;
@property(nonatomic, weak) IBOutlet UILabel *dishNameLabel;
@property(nonatomic, weak) IBOutlet UIScrollView *dishNameScrollView;
@property(nonatomic, weak) IBOutlet UIImageView *quantityBgImageView;
@property(nonatomic, weak) IBOutlet UITextField *quantityTextField;
@property(nonatomic, weak) IBOutlet UIButton *quantityReduceButton;
@property(nonatomic, weak) IBOutlet UIButton *quantityAddButton;
@property(nonatomic, weak) IBOutlet UITableView *cookbookPackageTableView;
@property(nonatomic, weak) IBOutlet UIButton *remarkButton;
@property(nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
@property(nonatomic, weak) IBOutlet UIImageView *handleBtnBgImageView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
@property(nonatomic, weak) IBOutlet UIButton *trueButton;

//优惠价格.
@property (strong, nonatomic) IBOutlet UILabel *promotePrice;



@property(nonatomic, strong) DtMenuCookbookDataClass *cookbookDataClass;
@property(nonatomic, strong) NSArray *cuisineRemarkArray;
@property(nonatomic, assign) int housingId;

/**
 * @brief   尝试关闭视图。
 *
 */
- (void)tryDismissView;

@end
