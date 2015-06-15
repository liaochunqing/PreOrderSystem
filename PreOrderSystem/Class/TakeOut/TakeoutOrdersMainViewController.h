//
//  TakeoutOrdersMainViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-8-23.
//
//“外卖”主页面

#import <UIKit/UIKit.h>

#import "RuleTakeoutSettingViewController.h"
#import "OrderMessageDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "OrderListLoadMoreCell.h"
#import "JsonPicker.h"

@class CustomDatePicker;

@interface TakeoutOrdersMainViewController : UIViewController<UIActionSheetDelegate, EGORefreshTableHeaderDelegate, UITextFieldDelegate, JsonPickerDelegate, UIAlertViewDelegate>
{
    __weak UITableView *orderMessagesTableview;
    __weak UIImageView *tableViewBgImageView;
    
    NSMutableArray *orderMsgArray;//外卖数据
    NSMutableArray *reasonOptionsArray;//取消原因数据
    NSMutableArray *reminderOptionsArray;//催单选项数据
    CustomDatePicker *customPicker;//时间选择器
    NSMutableArray *timeSearchArray;//保存时间查询的内容
    NSMutableArray *statusArray;//状态列表
    NSInteger statusSelectedIndex;//状态列表被选中索引
    
    RuleTakeoutSettingViewController *ruleTakeoutSettingCtrl;
    OrderMessageDetailViewController *detail;
    JsonPicker *jsonPicker;
    BOOL _reloading; //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    OrderListLoadMoreCell *loadMoreOrdersCell;
    
    int selectedRowIndex;
    int currentPageIndex;
    int totalRow;
    int totalPage;
   
    int duc;// 标记房台列表的“未读”的数目
    int puc;// 标记订座列表的“未读”的数目
    int tuc;// 标记外卖列表的“未读”的数目
    int muc;// 标记服务列表的“未读”的数目
    int ruc;// 标记外卖列表的“催单”的数目
    
    BOOL isShowing;
    
    int selectedOrderId;//正在查看的订单的id
    int pushOrderId;//推送过来的订单的id
    NSTimer *pauseTimer;//暂停外卖的定时器
    int pauseTimeCount;//暂停的时间长
    BOOL isStatusAll;//初始化默认状态选择全部
}
@property (weak, nonatomic) IBOutlet UITextField *endDate;

@property (weak, nonatomic) IBOutlet UITextField *startDate;
@property (nonatomic, strong) NSString *conditionKeyWord;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *mealTimesLabel;
@property (weak, nonatomic) IBOutlet UIButton *mealTimesButton;
@property (nonatomic, weak) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (nonatomic, weak) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageview;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
/// 电话外卖按钮
@property (nonatomic, weak) IBOutlet UIButton *telTakeoutButton;

@property (nonatomic, weak) IBOutlet UIImageView *searchBgImageView;
@property (nonatomic, weak) IBOutlet UITextField *searchTextfield;
@property (nonatomic, weak) IBOutlet UILabel *shopLabel;
@property (nonatomic, weak) IBOutlet UIImageView *shopArrowImageView;
@property (nonatomic, weak) IBOutlet UIButton *shopButton;
@property (nonatomic, weak) IBOutlet UITableView *orderMessagesTableview;
@property (nonatomic, weak) IBOutlet UIView *subview;
@property (nonatomic, weak) IBOutlet UIImageView *tableViewBgImageView;
@property (nonatomic, strong) NSString *mobileSearchNumber;
@property (weak, nonatomic) IBOutlet UILabel *stateVirtualLabel;

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

//Public Methods
-(void)showInView:(UIView*)aView;
-(void)dismissView;

- (IBAction)stateBtnClick:(UIButton *)sender;
- (IBAction)mealTimeBtnClick:(UIButton *)sender;
- (IBAction)orederTimeBtnClick:(UIButton *)sender;
@end
