//
//  PreorderMessageDetailViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//订座或外卖的详细页面
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
    
    //order==1, 订座; order==2, 外卖
    int orderType;
    int orderStatus;
    UIPopoverController *popoverController;
    
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
@property (nonatomic, weak) IBOutlet UIButton *leftSideButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *editSaveButton;
@property (nonatomic, weak) IBOutlet UIButton *editCancelButton;
@property (nonatomic, weak) IBOutlet UITableView *detailTableview;
@property (nonatomic, weak) IBOutlet UILabel *stateTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *stateLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderTypeInfoLabel;
@property (nonatomic, weak) IBOutlet UIImageView *handleBtnBG;
@property (nonatomic, weak) IBOutlet UIImageView *handleBtnBG2;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *trueButton;
@property (nonatomic, weak) IBOutlet UIButton *signButton;
@property (nonatomic, weak) IBOutlet UIButton *deliveryButton;
@property (nonatomic, weak) IBOutlet UIButton *checkInButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton2;
@property (nonatomic, weak) IBOutlet UIButton *reasonButton;
@property (nonatomic, weak) IBOutlet UIButton *printButton;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *tableHeadBgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *gradualImageView;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, assign) NSInteger orderId;
@property (nonatomic, strong) NSMutableArray *reasonOptionsArray;
@property (nonatomic, assign) BOOL isShowingView;//是否在显示视图，外卖详细订单时用

//Public Methods
- (void)showInView:(UIView*)aView;
- (void)dismissView;

//刷新订单数据
- (void)updateInfo:(NSDictionary*)info;

@end
