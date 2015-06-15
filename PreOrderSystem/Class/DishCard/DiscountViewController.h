//
//  DiscountViewController.h
//  PreOrderSystem
//
//  Created by mac on 14-7-1.
//
//

#import "DiscountDataModel.h"
#import "EGORefreshTableHeaderView.h"
#import "EditDiscountViewController.h"
#import "JsonPicker.h"
#import "MainViewController.h"  
#import "UIViewController+MJPopupViewController.h"
#import <UIKit/UIKit.h>
@class DiscountViewController;
@protocol DiscountViewControllerDelegate <NSObject>

- (void)DiscountViewController:(DiscountViewController *)ctrl didDismissView:(BOOL)flag;

@end


@interface DiscountViewController : UIViewController<EditDiscountViewControllerProtocol,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,EGORefreshTableHeaderDelegate,UITextFieldDelegate>

@property (nonatomic, weak) id <DiscountViewControllerDelegate> delegate;

//取消按钮
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;

//确定按钮
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

//添加优惠组合按钮
@property (strong, nonatomic) IBOutlet UIButton *addDiscountBtn;

//编号
@property (strong, nonatomic) IBOutlet UILabel *discountNumLabel;

//优惠组合名
@property (strong, nonatomic) IBOutlet UILabel *discountNameLabel;

//启用/停用
@property (strong, nonatomic) IBOutlet UILabel *switchLabel;


//删除组合
@property (strong, nonatomic) IBOutlet UILabel *deleteLabel;

@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;


//优惠组合列表
@property (strong, nonatomic) IBOutlet UITableView *discountListTableView;

//所有菜系菜品原始数据(未解析)
@property (nonatomic,strong) NSArray *allCuisineDataArr;

// 下拉刷新视图
@property (nonatomic,strong)EGORefreshTableHeaderView *RefreshHeaderView;

//下拉刷新用到的一个变量,作用未知
@property (nonatomic,assign)BOOL reloading;

//搜索按钮
@property (strong, nonatomic) IBOutlet UIButton *searchBtn;

//搜索输入框
@property (strong, nonatomic) IBOutlet UITextField *searchTextfield;

//是否处于搜索状态
@property (nonatomic, assign)BOOL isSearching;

-(void)showInView:(UIView*)aView;

-(void)dismissView;

@end
