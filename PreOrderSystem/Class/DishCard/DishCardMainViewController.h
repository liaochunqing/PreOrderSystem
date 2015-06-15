//
//  DishCardMainViewController.h
//  PreOrderSystem
//
//  Created by sWen on 13-4-9.
//
//菜牌页面

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "JsonPicker.h"
#import "DishCardItemDetailPicker.h"
#import "DishCardNewViewController.h"
#import "EditCuisineViewController.h"
#import "DishCardRemarkViewController.h"
#import "promotionMainViewController.h"
#import "EditDiscountViewController.h"
#import "DiscountViewController.h"
@interface DishCardMainViewController : UIViewController<EGORefreshTableHeaderDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, EditCuisineViewControllerDelegate, DishCardItemDetailPickerDelegate, DishCardRemarkViewControllerDelegate,promotionMainViewControllerDelegate,UIGestureRecognizerDelegate, DishCardNewViewControllerDelegate,DiscountViewControllerDelegate>
{
    __weak UIImageView *bgImageView;
    __weak UITableView *dishCardTableview;
    __weak UITextField *searchbarTextfield;
    __weak UIScrollView *cuisineScrollview;
    __weak UIButton *moreBtn;
    //下拉刷新
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    JsonPicker *jsonPicker;
    
    BOOL isSearching;
    NSMutableArray *allDishCardListArray;
    NSMutableArray *filterDishCardListArray;
    NSString *imgBaseURL;
    
    int selectedCuisineIndex;
    BOOL isDeletingFlag;//是否正在删除状态
    
    DiscountViewController *discountViewController_;
    
    
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *searchBgImageView;
@property (nonatomic, weak) IBOutlet UITableView *dishCardTableview;
@property (nonatomic, weak) IBOutlet UITextField *searchbarTextfield;
@property (nonatomic, weak) IBOutlet UIScrollView *cuisineScrollview;
@property (nonatomic, weak) IBOutlet UIButton *addDishBtn;
@property (nonatomic, weak) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *promotiomGroupButton;
@property (weak, nonatomic) IBOutlet UIButton *promotionButton;
@property (nonatomic, strong) NSString *imgBaseURL;

- (IBAction)promotionBtnClick:(UIButton *)sender;
- (IBAction)promotiongBtnClick:(UIButton *)sender;
- (IBAction)addDishCardItemButtonPressed:(UIButton*)sender;
- (IBAction)moreButtonPressed:(UIButton*)sender;
- (void)showInView:(UIView*)aView;
- (void)dismissView;
@end
