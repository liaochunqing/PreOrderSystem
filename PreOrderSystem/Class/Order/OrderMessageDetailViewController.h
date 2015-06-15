//
//  PreorderMessageDetailViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "JsonPicker.h"
#import "ReasonViewController.h"
#import "DishDetailTitleView.h"

@class OrderMessageDetailViewController;
@protocol OrderMessageDetailViewControllerDelegate <NSObject>
-(void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)detailController didChecked:(BOOL)isChecked newOrderStatus:(int)status;
-(void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)detailController didUpdatedInfo:(NSDictionary*)info;
-(void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)picker didDismissView:(UIButton*)sender;
@end

/**
 * @brief   订座或外卖的详细页面。
 *
 *
 */
@interface OrderMessageDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, JsonPickerDelegate, ReasonViewControllerDelegate, DishDetailTitleViewDelegate>
{
    __weak id <OrderMessageDetailViewControllerDelegate> delegate;
    __weak UIButton *leftSideButton;
    __weak UIButton *editButton;
    __weak UIButton *editSaveButton;
    __weak UIButton *editCancelButton;
    __weak UITableView *detailTableview;
    __weak UILabel *stateLabel;
    __weak UILabel *nameLabel;
    __weak UILabel *phoneLabel;
    __weak UILabel *orderTypeInfoLabel;
    __weak UIImageView *handleBtnBG;//取消订单，确定订单两个按钮的背景图片
    __weak UIImageView *handleBtnBG2;//送餐、签收、取消三个按钮的背景图
    __weak UIButton *cancelButton;//取消订单
    __weak UIButton *trueButton;//确定订单
    __weak UIButton *signButton;//客人签到
    __weak UIButton *deliveryButton;//送餐
    __weak UIButton *checkInButton;//签收
    __weak UIButton *cancelButton2;//外卖确定订单后的取消
    __weak UIButton *reasonButton;//取消原因
    __weak UIImageView *bgImageView;
    __weak UIImageView *tableHeadBgImageView;
    __weak UIImageView *gradualImageView;//渐变图片
    
    //用于设置是否处于编辑状态（修改“订座时间”、“订座人数”、“选台”）
    BOOL isEditing;
    //用于判断是否己修改
    BOOL isEdited;
    int orderStatus;
    id popoverController;
    
    //临时的订单Info
    NSMutableDictionary *orderDetailInfo;
    //正式的订单Info
    NSDictionary *msgDetailInfo;
    JsonPicker *jsonPicker;
    BOOL isOpenDetailDish;//菜是否展开
    int deliveryType;//外卖送餐方式 0送餐上门, 1自取
//    NSMutableArray *paymentWay;//付款方式
}

@property (nonatomic, weak) id delegate;
/// 返回按钮
@property (nonatomic, weak) IBOutlet UIButton *backButton;
/// 标题视图
@property (nonatomic, weak) IBOutlet UILabel *orderTypeInfoLabel;
/// 编辑按钮
@property (nonatomic, weak) IBOutlet UIButton *editButton;
/// 编辑提交按钮
@property (nonatomic, weak) IBOutlet UIButton *editSaveButton;
/// 编辑取消按钮
@property (nonatomic, weak) IBOutlet UIButton *editCancelButton;
/// 详情内容视图
@property (nonatomic, weak) IBOutlet UITableView *detailTableview;
/// 状态标题视图
@property (nonatomic, weak) IBOutlet UILabel *stateTitleLabel;
/// 状态视图
@property (nonatomic, weak) IBOutlet UILabel *stateLabel;
/// 称呼标题视图
@property (nonatomic, weak) IBOutlet UILabel *nameTitleLabel;
/// 称呼视图
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
/// 手机标题视图
@property (nonatomic, weak) IBOutlet UILabel *phoneTitleLabel;
/// 手机视图
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
/// 按钮背景视图（两个按钮）
@property (nonatomic, weak) IBOutlet UIImageView *handleBtnBG;
/// 按钮背景视图（三个按钮）
@property (nonatomic, weak) IBOutlet UIImageView *handleBtnBG2;
/// 取消订单按钮（等待确认状态下）
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
/// 确认订单按钮（等待确认状态下）
@property (nonatomic, weak) IBOutlet UIButton *trueButton;
/// 客人签到按钮（订座详情）
@property (nonatomic, weak) IBOutlet UIButton *signButton;
/// 送餐按钮（订单生效状态下）
@property (nonatomic, weak) IBOutlet UIButton *deliveryButton;
/// 取消按钮（订单生效状态下）
@property (nonatomic, weak) IBOutlet UIButton *cancelButton2;
/// 催单按钮（订单生效状态下）
@property (nonatomic, weak) IBOutlet UIButton *reminderButton;
/// 签收按钮（未使用）
@property (nonatomic, weak) IBOutlet UIButton *checkInButton;
/// 查看取消原因按钮（订单失效状态下）
@property (nonatomic, weak) IBOutlet UIButton *reasonButton;
/// 打印订单按钮
@property (nonatomic, weak) IBOutlet UIButton *printButton;
/// 背景视图
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
/// 渐变层图片视图
@property (nonatomic, weak) IBOutlet UIImageView *gradualImageView;
/// 标记
@property (nonatomic, assign) NSInteger tag;
/// 弹出窗（订座时间、人数、选台修改的弹出窗）
@property (nonatomic, strong) UIPopoverController *popoverController;
/// 订单编号
@property (nonatomic, assign) NSInteger orderId;
/// 取消原因列表
@property (nonatomic, strong) NSMutableArray *reasonOptionsArray;
/// 催单选项列表
@property (nonatomic, strong) NSMutableArray *reminderOptionsArray;
/// 是否在显示视图，外卖详细订单时用
@property (nonatomic, assign) BOOL isShowingView;
/// 订单类型（1：订座，2：外卖）
@property (nonatomic) int orderType;

/**
 * @brief   显示视图。
 *
 * @param   aView   视图的父视图。
 *
 */
- (void)showInView:(UIView*)aView;

/**
 * @brief   隐藏视图。
 *
 */
- (void)dismissView;

/**
 * @brief   刷新订单数据。
 *
 * @param   info    详细内容。
 *
 */
- (void)updateInfo:(NSDictionary*)info;

@end
