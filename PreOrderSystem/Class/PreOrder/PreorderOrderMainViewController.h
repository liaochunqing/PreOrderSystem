//
//  PreOrderMainViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//“订座”主页面
#import <UIKit/UIKit.h>

#import "RulePreorderSettingViewController.h"
#import "OrderMessageDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "OrderListLoadMoreCell.h"
#import "JsonPicker.h"

@class CustomDatePicker;

@interface PreorderOrderMainViewController : UIViewController<UIActionSheetDelegate, EGORefreshTableHeaderDelegate, UITextFieldDelegate, JsonPickerDelegate>
{
    __weak UIButton *editButton;
    __weak UITableView *orderMessagesTableview;
    __weak UIImageView *tableViewBgImageView;
    
    //订座数据
    NSMutableArray *orderMsgArray;
    CustomDatePicker *customPicker;
    NSMutableArray *timeSearchArray;//保存时间查询的内容
    NSMutableArray *reasonOptionsArray;//取消原因数据
    RulePreorderSettingViewController *rulePreorderSettingCtrl;
    OrderMessageDetailViewController *detail;
    JsonPicker *jsonPicker;
    
    NSMutableArray *statusArray;//状态列表
    NSInteger statusSelectedIndex;//状态列表被选中索引
    
    BOOL _reloading;//下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    OrderListLoadMoreCell *loadMoreOrdersCell;
    
    int selectedRowIndex;
    int currentPageIndex;
    int totalRow;
    int totalPage;
    
    int duc;//标记房台列表的“未读”的数目
    int puc;//标记订座列表的“未读”的数目
    int tuc;//标记外卖列表的“未读”的数目
    int muc;//标记服务列表的“未读”的数目
    int ruc;//标记外卖列表的“催单”的数目
    
    BOOL isShowing;//判断页面是否在显示
    int selectedOrderId;//正在查看的订单的id
    int pushOrderId;//推送过来的订单的id
    BOOL isStatusAll;//初始化默认状态选择全部
}
/// 开始日期文本框
@property (weak, nonatomic) IBOutlet UITextField *startDate;
/// 截止日期文本框
@property (weak, nonatomic) IBOutlet UITextField *endDate;
/// 是否正在显示
@property (nonatomic, assign) BOOL isShowing;
/// 姓名标题视图
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
/// 人数标题视图
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
/// 手机号码标题视图
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
/// 入座时间标题按钮
@property (weak, nonatomic) IBOutlet UIButton *mealTimeButton;
/// 入座时间标题视图
@property (nonatomic, weak) IBOutlet UILabel *mealTimesLabel;
/// 下单时间标题按钮
@property (weak, nonatomic) IBOutlet UIButton *orderTimeButton;
/// 下单时间标题视图
@property (nonatomic, weak) IBOutlet UILabel *orderTimeLabel;
/// 状态下拉三角视图
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
/// 状态标题视图（为了设置弹出框的位置）
@property (weak, nonatomic) IBOutlet UILabel *stateVirtualLabel;
/// 状态按钮
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
/// 状态标题视图
@property (nonatomic, weak) IBOutlet UILabel *stateLabel;
/// 搜索文本框
@property (nonatomic, weak) IBOutlet UITextField *searchTextfield;
/// 设置按钮
@property (nonatomic, weak) IBOutlet UIButton *editButton;
/// 电话订座按钮
@property (nonatomic, weak) IBOutlet UIButton *orderByPhoneButton;
/// 分店名称视图
@property (nonatomic, weak) IBOutlet UILabel *shopLabel;
/// 分店下拉三角视图
@property (nonatomic, weak) IBOutlet UIImageView *shopArrowImageView;
/// 分店按钮
@property (nonatomic, weak) IBOutlet UIButton *shopButton;
/// 订座列表视图
@property (nonatomic, weak) IBOutlet UITableView *orderMessagesTableview;
/// 容器视图
@property (nonatomic, weak) IBOutlet UIView *subview;
/// 列表背景视图
@property (nonatomic, weak) IBOutlet UIImageView *tableViewBgImageView;
/// 搜索背景视图
@property (nonatomic, weak) IBOutlet UIImageView *searchBgImageView;
/// 列表头部背景视图
@property (nonatomic, weak) IBOutlet UIImageView *headTitleBgImageView;
/// 搜索字符串
@property (nonatomic, strong) NSString *mobileSearchNumber;

//Public Methods
-(void)showInView:(UIView*)aView;
- (IBAction)stateBtnClick:(UIButton *)sender;
-(void)dismissView;
- (IBAction)mealTimeBtnClick:(UIButton *)sender;
- (IBAction)orderTimeBtnClick:(UIButton *)sender;

@end
