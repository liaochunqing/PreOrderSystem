//
//  DtMenuMainViewController.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import <UIKit/UIKit.h>

#import "DtMenuListTableViewCell.h"
#import "JsonPicker.h"
#import "EGORefreshTableHeaderView.h"
#import "DtMenuCookbookViewController.h"
#import "DtMenuCookbookPackageViewController.h"
#import "DtMenuShoppingCarViewController.h"
#import "DiningTableCommon.h"
#import "DtMenuShoppingCarViewController.h"

@class HousingButtonCell;

@class HousingDataClass;
@class DtMenuMainViewController;
@protocol DtMenuMainViewControllerDelegate <NSObject>

- (void)dtMenuMainViewHavedDismiss:(HousingButtonCell *)cell withHousingData:(HousingDataClass *)dataClass flag:(BOOL)flag;

@end

@interface DtMenuMainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DtMenuListTableViewCellDelegate, JsonPickerDelegate, EGORefreshTableHeaderDelegate, DtMenuCookbookViewControllerDelegate, DtMenuCookbookPackageViewControllerDelegate, DtMenuShoppingCarViewControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@property(nonatomic, weak) id <DtMenuMainViewControllerDelegate> delegate;
@property(nonatomic, weak) IBOutlet UIButton *shoppingCarButton;
@property(nonatomic, weak) IBOutlet UIButton *backButton;
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UIScrollView *cuisineScrollView;
@property(nonatomic, weak) IBOutlet UITableView *menuTableView;
@property(nonatomic, strong) NSString *areaName;
@property(nonatomic, strong) HousingDataClass *housingDataClass;
@property(nonatomic, strong) HousingButtonCell *housingButtonCell;
@property(nonatomic, assign) kHousingStateType housingStateType;
@property(nonatomic, assign) int tag;

//房台区域
@property (strong, nonatomic) IBOutlet UITextField *roomAreaTextField;

//台号
@property (strong, nonatomic) IBOutlet UITextField *tableNameTextField;

//入座时间
@property (strong, nonatomic) IBOutlet UITextField *seatTimeTextField;

//人数
@property (strong, nonatomic) IBOutlet UITextField *peopleNumTextField;

//会员号
@property (strong, nonatomic) IBOutlet UITextField *userNumberTextField;

//会员名称
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;

//会员积分
@property (strong, nonatomic) IBOutlet UITextField *membershipPointTextField;

//会员详情按钮
@property (strong, nonatomic) IBOutlet UIButton *userDetailInfoBtn;

// 入座时间选择视图
@property (nonatomic, strong) UIDatePicker *datetimePicker;

@end
