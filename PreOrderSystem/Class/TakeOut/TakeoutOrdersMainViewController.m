//
//  TakeoutOrdersMainViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-8-23.
//
//

#import "TakeoutOrdersMainViewController.h"
#import "Constants.h"
#import "MainViewController.h"
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "OrderMessageDetailViewController.h"
#import "TakeOutTableViewCell.h"
#import "UILabel+AdjustFontSize.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "CustomDatePicker.h"
#import "OfflineManager.h"
#import "StaffManagementSuperDataClass.h"
#import "CustomPopoverTouchView.h"
#import "TakeOutShopListView.h"
#import "NsstringAddOn.h"
#import "UIViewController+ShowInView.h"
#import "TakeoutByPhoneViewController.h"
#import "UITextFieldAddition.h"

#define kPhoneNumberLength 11
#define kMoreActionSheetTag 1100
#define kStateActionSheetTag 1400
#define kTimerActionSheetTag 1200
#define kTimerAlertViewTag 1300
#define kStartTime1ForPause 30   /*30分钟*/
#define kStartTime2ForPause 60   /*1小时*/
#define kStartTime3ForPause 120  /*2小时*/
#define kSecondForPerMinute 60   /*1分钟为60秒*/
#define kMinuteForPerHour 60   /*1小时为60分钟*/

#define kStartTimeActionSheetTag 1
#define kEndTimeActionSheetTag 2
#define kStartTimeDatePickerTag 3
#define kEndTimeDatePickerTag 4

@interface TakeoutOrdersMainViewController ()<CustomPopoverTouchViewDelegate, TakeOutShopListViewDelegate,
TakeoutByPhoneViewControllerDelegate> {
    BOOL deliveryOpenFlag;
    BOOL selfhelpOpenFlag;
    TakeOutShopListView *shopListView;
    CustomPopoverTouchView *customTouchView;
    NSInteger branchId;//连锁店id
    /// 电话外卖视图控制器
    TakeoutByPhoneViewController *takeoutByTelViewController_;
    
    //电话外卖,默认选项(YES:自取 NO:送餐)
    BOOL phoneOrderTypeDefault_;
    
    //电话外卖输入资料的顺序,0：点菜后台填写用户信息,1：填写用户信息后点菜
    BOOL phoneOrderInputTypeDefault_;
    
    
    //标记当前页是否为外卖的子视图
    BOOL isInSubView_;
}

@end

@implementation TakeoutOrdersMainViewController

@synthesize conditionKeyWord;
@synthesize isShowing;
@synthesize editButton;
@synthesize orderMessagesTableview;
@synthesize tableViewBgImageView;

#pragma mark LIFE CYCLE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 创建关闭按钮
    [self.searchTextfield bindCloseButton];
    
    selectedRowIndex = -1;
    selectedOrderId = -1;
    currentPageIndex = 1;
    totalPage = 0;
    totalRow = 0;
    branchId = 0;
    isStatusAll = YES;
    orderMsgArray = [[NSMutableArray alloc] init];
    reasonOptionsArray = [[NSMutableArray alloc] init];
    reminderOptionsArray = [[NSMutableArray alloc] init];
    statusArray = [[NSMutableArray alloc] init];
    
    self.mealTimesButton.selected = YES;//默认送达时间排序
    [self updateQueueStatus];
    
    [self addPictureToView];
    [self addLocalizedString];
    [self updateTakeOutAuthority];
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSDictionary *dict = [offlineMgr fetchDefaultOrderFilterDateData];
    
    if (dict)// 日期搜索默认时间
    {
        NSDictionary *bookDict = [dict objectForKey:@"takeout"] ;
        
        if (bookDict)
        {
            self.startDate.text = [bookDict objectForKey:@"start"] ;
            self.endDate.text = [bookDict objectForKey:@"end"] ;
        }
    }
    
    NSArray *shopArray = [offlineMgr fetchBranchShopData];
    if ([shopArray count]) {
        NSString *shopName = [[shopArray firstObject] objectForKey:@"name"];
        self.shopLabel.text = shopName;
        self.shopLabel.hidden = self.shopButton.hidden = self.shopArrowImageView.hidden = NO;
        self.searchBgImageView.image = LoadImageWithPNGType(@"order_searchBg");
        self.shopArrowImageView.image = LoadImageWithPNGType(@"order_shopDownArrow");
    } else {
        self.shopLabel.text = @"";
        self.shopLabel.hidden = self.shopButton.hidden = self.shopArrowImageView.hidden = YES;
        
        self.searchBgImageView.image = LoadImageWithPNGType(@"order_searchSecondBg");
        self.shopArrowImageView.image = nil;
        
        self.searchTextfield.frame = CGRectMake(496.0, self.searchTextfield.frame.origin.y, 320.0, self.searchTextfield.frame.size.height);
        
        CGRect frame1 = self.startDate.frame;
        frame1.origin.x += 25;
        self.startDate.frame = frame1;
        
        CGRect frame2 = self.endDate.frame;
        frame2.origin.x += 75;
        self.endDate.frame = frame2;
    }
    
    if (!self.subview.hidden) {
        [self registerForNotifications];
        [self addPullDownReFresh];
        [self getTakeoutInfoData:currentPageIndex withAnimated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationMaskLandscape;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self unregisterFromNotifications];
    orderMsgArray = nil;
    customPicker = nil;
    timeSearchArray = nil;
    ruleTakeoutSettingCtrl = nil;
    detail = nil;
    _refreshHeaderView = nil;
    loadMoreOrdersCell = nil;
    jsonPicker = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"takeout") forKey:@"title"];//崩
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
    isShowing = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    /*
     if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
     {
     [self viewDidUnload];
     [self setView:nil];
     }
     */
}

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"===TakeoutOrdersMainViewController,dealloc===");
#endif
    [self unregisterFromNotifications];
}

// 下拉刷新
- (void)addPullDownReFresh
{
    // 初始化“下拉刷新”控件
    _reloading = NO;
    
    if (_refreshHeaderView == nil) {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - orderMessagesTableview.bounds.size.height, self.view.frame.size.width, orderMessagesTableview.bounds.size.height)];
        _refreshHeaderView.backgroundColor = [UIColor clearColor];
		_refreshHeaderView.delegate = self;
		[orderMessagesTableview addSubview:_refreshHeaderView];
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}

// 显示时间ActionSheet
- (void)showStartTimeActionSheet:(NSInteger)actionSheetTag withDatePickerDate:(NSDate *)pickerDate withDatePickerTag:(NSInteger)datePickerTag withRect:(CGRect)showRect
{
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:kLoc(@"confirm")
                                  otherButtonTitles:nil];
    actionSheet.tag = actionSheetTag;
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
    if (kIsiPhone) {
        picker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
    }
    picker.backgroundColor = [UIColor clearColor];
    picker.tag = datePickerTag;
    picker.datePickerMode = UIDatePickerModeDate;
    picker.date = pickerDate;
    [actionSheet addSubview:picker];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:showRect inView:self.subview animated:YES];
    }
}

- (void)showInView:(UIView*)aView
{
    self.view.alpha = 0.0f;
    
    CGRect frame = self.view.frame;
    frame.origin.x = 170;
    self.view.frame = frame;
    
    [aView addSubview:self.view];
    
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    
    self.view.alpha = 1.0f;
    
    CGRect aFrame = self.view.frame;
    aFrame.origin.y = 0;
    self.view.frame = aFrame;
	[UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[self.view removeFromSuperview];
}

- (void)dismissView
{
    [detail dismissView];
    selectedOrderId = -1;
    [ruleTakeoutSettingCtrl dismissView];
    
    if (takeoutByTelViewController_ != nil) {
        // 如果电话外卖页面没有关闭，强制关闭
        [takeoutByTelViewController_ dismissViewControllerWithAnimated:NO];
        takeoutByTelViewController_ = nil;
        
        // 显示UI
        isInSubView_ = NO;
        self.telTakeoutButton.hidden = NO;
        self.tableViewBgImageView.hidden = NO;
        self.pauseButton.hidden = NO;
        self.editButton.hidden = NO;
        self.subview.hidden = NO;
    }
    
    if (selectedRowIndex >= 0) {
        [orderMessagesTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRowIndex inSection:0] animated:NO];
        selectedRowIndex = -1;
    }
    isShowing = NO;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:1.0f];
    
    CGRect aFrame = self.view.frame;
    //aFrame.origin.y = 500;
    self.view.frame = aFrame;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //self.view.alpha = 0.0f;
    [UIView commitAnimations];
}



- (void)addLocalizedString
{
    self.nameLabel.text = kLoc(@"name");
    self.phoneLabel.text = kLoc(@"phone_number");
    self.mealTimesLabel.text = kLoc(@"reach_time");
    self.orderTimeLabel.text = kLoc(@"order_time");
    self.stateLabel.text = kLoc(@"status");
    self.searchTextfield.placeholder = kLoc(@"phone_number");
    [self.telTakeoutButton setTitle:kLoc(@"phone_order") forState:UIControlStateNormal];
    [self.pauseButton setTitle:kLoc(@"pause_takeout") forState:UIControlStateNormal];
}

- (void)addPictureToView
{
    tableViewBgImageView.image = [UIImage imageFromMainBundleFile:@"order_frameBg.png"];
    [self.telTakeoutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_pauseBg.png"]
                                     forState:UIControlStateNormal];
    [self.pauseButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_pauseBg.png"]
                                forState:UIControlStateNormal];
}

- (void)updateTakeOutAuthority
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    for (NSDictionary *authDict in authorityArray)
    {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfTakeoutIndexStr])
        {
            for (StaffManagementSubAuthDataClass *subAuth in authClass.childrenArray)
            {
                if ([subAuth.indexStr isEqualToString:@"pausing"])
                {
                    self.pauseButton.enabled = subAuth.open;
                }
                else if ([subAuth.indexStr isEqualToString:@"deliverySetting"])
                {
                    deliveryOpenFlag = subAuth.open;
                }
                else if ([subAuth.indexStr isEqualToString:@"selfhelpSetting"])
                {
                    selfhelpOpenFlag = subAuth.open;
                }
                else if ([subAuth.indexStr isEqualToString:@"main"])
                {
                    self.subview.hidden = !subAuth.open;
                }
            }
            break;
        }
    }
    
    if (isInSubView_)
    {
        self.subview.hidden = YES;
    }
    
    if (!deliveryOpenFlag && !selfhelpOpenFlag)
    {
        self.editButton.enabled = NO;
    }
    else
    {
        self.editButton.enabled = YES;
    }
}

- (void)updateQueueStatus
{
    self.mealTimesLabel.textColor = [UIColor blackColor];
    self.orderTimeLabel.textColor = [UIColor blackColor];
    self.stateImageview.image = [UIImage imageNamed:@"order_shopDownArrow"];
    
    if (self.mealTimesButton.selected) {
        self.mealTimesLabel.textColor = [UIColor orangeColor];
    } else if (self.orderTimeButton.selected) {
        self.orderTimeLabel.textColor = [UIColor orangeColor];
    }
}

#pragma mark -Private method

//NSDictionary转JSonStr
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - UIButton Clicked

- (IBAction)mealTimeBtnClick:(UIButton *)sender
{
    if (sender.selected) return;
    
    [self.searchTextfield resignFirstResponder];
    // 带上手机号码条件
    self.mobileSearchNumber = self.searchTextfield.text;
    
    sender.selected = !sender.selected;
    self.orderTimeButton.selected = NO;
    [self updateQueueStatus];
    [self getTakeoutInfoData:1 withAnimated:YES];
}

- (IBAction)orederTimeBtnClick:(UIButton *)sender
{
    if (sender.selected) return;
    
    [self.searchTextfield resignFirstResponder];
    // 带上手机号码条件
    self.mobileSearchNumber = self.searchTextfield.text;
    
    sender.selected = !sender.selected;
    self.mealTimesButton.selected = NO;
    [self updateQueueStatus];
    [self getTakeoutInfoData:1 withAnimated:YES];
}

- (IBAction)stateBtnClick:(UIButton *)sender
{
    [self.searchTextfield resignFirstResponder];
    
    sender.selected = !sender.selected;
    if (statusArray.count == 0) return;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (int i = 0; i < statusArray.count; i++)
    {
        NSString *string = [NSString stringWithFormat:@"%@" ,kLoc([statusArray[i] objectForKey:@"name"])];
        [actionSheet addButtonWithTitle:string];
    }
    
    actionSheet.tag = kStateActionSheetTag;
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:self.stateVirtualLabel.frame inView:self.subview animated:YES];
    }
}

// “编辑”按钮点击
- (IBAction)editButtonPressed:(UIButton*)sender
{
    [self.searchTextfield resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (deliveryOpenFlag) {
        [actionSheet addButtonWithTitle:kLoc(@"deliver_meal_and_takeout_settings")];
    }
    if (selfhelpOpenFlag) {
        [actionSheet addButtonWithTitle:kLoc(@"take_meal_and_takeout_settings")];
    }
    actionSheet.tag = kMoreActionSheetTag;
    
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
    }
}

// 暂停外卖
-(IBAction)pauseButtonPressed:(UIButton*)sender
{
    [self.searchTextfield resignFirstResponder];
    
    if ([pauseTimer isValid]) {
        
        NSString *title = [NSString stringWithFormat:@"%@？",kLoc(@"confirm_to_resume_takeout")];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:kLoc(@"confirm")
                                              otherButtonTitles:kLoc(@"cancel"), nil];
        alert.tag = kTimerAlertViewTag;
        [alert show];
    } else {
        NSString *firstStr = [NSString stringWithFormat:@"30%@", kLoc(@"minute")];
        NSString *secondStr = [NSString stringWithFormat:@"1%@", kLoc(@"hour")];
        NSString *thirdStr = [NSString stringWithFormat:@"2%@", kLoc(@"hour")];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        [actionSheet addButtonWithTitle:firstStr];
        [actionSheet addButtonWithTitle:secondStr];
        [actionSheet addButtonWithTitle:thirdStr];
        actionSheet.tag = kTimerActionSheetTag;
        
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
        }
    }
}

/**
 * @brief   电话订座按钮事件。
 *
 */
- (IBAction)telTakeoutButtonAction:(id)sender
{
    // 隐藏UI
    isInSubView_ = YES;
    self.telTakeoutButton.hidden = YES;
    self.tableViewBgImageView.hidden = YES;
    self.pauseButton.hidden = YES;
    self.editButton.hidden = YES;
    self.subview.hidden = YES;
    
    
    // 收起订单详细视图
    [detail dismissView];
    
    selectedOrderId = -1;
    if (selectedRowIndex >= 0) {
        [orderMessagesTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRowIndex inSection:0] animated:YES];
        selectedRowIndex = -1;
    }
    
    MainViewController *mainViewController = [MainViewController getMianViewShareInstance];
    
    if (takeoutByTelViewController_ != nil) {
        [takeoutByTelViewController_ dismissViewControllerWithAnimated:NO];
        takeoutByTelViewController_ = nil;
    }
    takeoutByTelViewController_ = [[TakeoutByPhoneViewController alloc] init];
    takeoutByTelViewController_.delegate = self;
    takeoutByTelViewController_.phoneOrderTypeDefault = phoneOrderTypeDefault_;
    takeoutByTelViewController_.phoneOrderInputTypeDefault = phoneOrderInputTypeDefault_;
    [takeoutByTelViewController_ showInView:mainViewController
                            withOriginPoint:kViewControllerOrigin
                               withAnimated:YES];
    
}

// 选择连锁店按钮
- (IBAction)shopBtnPressed:(UIButton *)sender
{
    [self.searchTextfield resignFirstResponder];
    
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *shopArray = [offlineMgr fetchBranchShopData];
    if ([shopArray count]) {
        self.shopArrowImageView.image = LoadImageWithPNGType(@"order_shopUpArrow");
        
        MainViewController *mainVC = [MainViewController getMianViewShareInstance];
        if (!customTouchView) {
            customTouchView = [[CustomPopoverTouchView alloc] initWithFrame:mainVC.view.frame];
        }
        customTouchView.delegate = self;
        [mainVC.view addSubview:customTouchView];
        
        if (!shopListView) {
            shopListView = [[TakeOutShopListView alloc] initWithFrame:CGRectZero];
        }
        shopListView.delegate = self;
        [shopListView showInView:mainVC.view withOriginPoint:kTakeOutShopListViewOrigin withAnimated:YES];
        [shopListView updateTakeOutShopListView:shopArray];
    }
}

#pragma mark pause takeout

- (void)updateSettingBtn:(NSDictionary *)dict
{
    if (0 == [dict count]) {
        return;
    }
    NSInteger countdown = [[dict objectForKey:@"countdown"]integerValue];
    /*暂停按钮是否可以用*/
    NSInteger quickSetting = [[dict objectForKey:@"quickSetting"]integerValue];
    self.pauseButton.enabled = YES;
    
    if (0 < countdown)
    {
        [self startTimer:countdown];
    }
    else
    {
        [self endTimer];
        if (0 == countdown && 0 == quickSetting)
        {
            self.pauseButton.enabled = NO;
        }
    }
    
    [self updateTakeOutAuthority];
}

// 启动定时器
- (void)startTimer:(NSInteger)countDown
{
    [self.pauseButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_countdownBg.png"] forState:UIControlStateNormal];
    [self.pauseButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [self.pauseButton setTitle:nil forState:UIControlStateNormal];
    self.editButton.enabled = NO;
    pauseTimeCount = (int)countDown;
    if ([pauseTimer isValid]) {
        [pauseTimer invalidate];
        pauseTimer = nil;
    }
    pauseTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateTimer
{
    if (0 < pauseTimeCount)
    {
        NSString *titleStr = nil;
        int minute = pauseTimeCount/kSecondForPerMinute;
        if (minute < kMinuteForPerHour) {
            /***是否大于一分钟***/
            if (pauseTimeCount <= kSecondForPerMinute) {
                titleStr = @"00:01";
            } else {
                /***是否大于十分钟***/
                if (pauseTimeCount < kSecondForPerMinute * 10) {
                    titleStr = [NSString stringWithFormat:@"00:0%d",minute];
                } else {
                    titleStr = [NSString stringWithFormat:@"00:%d",minute];
                }
            }
        } else if (kMinuteForPerHour == minute) {
            titleStr = @"01:00";
        } else if (minute > kMinuteForPerHour && minute < kStartTime3ForPause) {
            titleStr = [NSString stringWithFormat:@"01:%d",minute - kMinuteForPerHour];
        } else if (kStartTime3ForPause == minute) {
            titleStr = @"02:00";
        }
        [self.pauseButton setTitle:titleStr forState:UIControlStateNormal];
        
        --pauseTimeCount;
    } else {
        [self resumeTakeOut:NO];
    }
#ifdef DEBUG
    NSLog(@"===pauseTimeCount:%d,%@===", pauseTimeCount, self.pauseButton.titleLabel.text);
#endif
}

- (void)endTimer
{
    [self.pauseButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_pauseBg.png"]
                                forState:UIControlStateNormal];
    [self.pauseButton setTitleEdgeInsets:UIEdgeInsetsZero];
    [self.pauseButton setTitle:kLoc(@"pause_takeout") forState:UIControlStateNormal];
    self.editButton.enabled = YES;
    [pauseTimer invalidate];
    pauseTimer = nil;
}

#pragma mark network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

//获取外卖订单列表
- (void)getTakeoutInfoData:(int)page withAnimated:(BOOL)animated
{
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"updating_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[NSNumber numberWithInt:2] forKey:@"orderType"];
    [postData setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [postData setObject:[NSNumber numberWithInt:branchId] forKey:@"branchId"];
    
    // 送达时间 or 下单时间
    if (self.mealTimesButton.selected) {
        [postData setObject:@"carryTime" forKey:@"orderField"];
    } else if (self.orderTimeButton.selected) {
        [postData setObject:@"orderTime" forKey:@"orderField"];
    }
    
    // 状态
    NSInteger status = -1;
    if (statusArray && statusSelectedIndex < statusArray.count) {
        status = [[statusArray[statusSelectedIndex] objectForKey:@"status"] integerValue];
    }
    
    [postData setObject:[NSNumber numberWithInteger:status] forKey:@"status"];
    
    // 关键字
    if ([self.mobileSearchNumber length] > 0) {
        [postData setObject:self.mobileSearchNumber forKey:@"keyword"];
    }
    self.searchTextfield.text = self.mobileSearchNumber;
    
    //日期
    [postData setObject:self.startDate.text forKey:@"startDate"];
    [postData setObject:self.endDate.text forKey:@"endDate"];
    [jsonPicker postData:postData withBaseRequest:@"takeout/orderlist"];
}

//暂停外卖
- (void)pauseTakeOut:(int)pauseTime
{
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[NSNumber numberWithInt:pauseTime] forKey:@"time"];
    
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"modify_succeed");
    [jsonPicker postData:postData withBaseRequest:@"takeout/pause"];
}

//恢复外卖
- (void)resumeTakeOut:(BOOL)animated
{
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerThirdTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"modify_succeed");
    [jsonPicker postData:postData withBaseRequest:@"takeout/resume"];
}

- (int)textTransforNumber:(NSString *)levelStr
{
    int level = 0;
    if ([levelStr isEqualToString:kLoc(@"noon")]) {
        level = 0;
    } else if ([levelStr isEqualToString:kLoc(@"evening")]) {
        level = 1;
    } else {
        level = 2;
    }
    return level;
}

#pragma mark Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(updatedOrderListWhenEnterForeground) name:kUpdatedTakeoutOrderListWhenEnterForeground object:nil];
    [nc addObserver:self selector:@selector(updatedOrderListWhenPush:) name:kUpdateTakeoutOrderListWhenPush object:nil];
    [nc addObserver:self selector:@selector(updatedOrderListWithLocalOrder) name:kShouldUpdateTakeoutOrderListWithLocalOrder object:nil];
}

- (void)unregisterFromNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updatedOrderListWithLocalOrder
{
    [self getTakeoutInfoData:1 withAnimated:NO];
}

-(void)updatedOrderListWhenEnterForeground
{
    [self getTakeoutInfoData:1 withAnimated:NO];
}

-(void)updatedOrderListWhenPush:(NSNotification *)notify
{
    pushOrderId = [[notify.userInfo objectForKey:@"oid"]integerValue];
    [self getTakeoutInfoData:currentPageIndex withAnimated:NO];
}

// 更新badge（包括程序的badge、房台的badge、订座列表的badge、外卖列表的badge、服务列表的badge）
- (void)updateBadge
{
    NSDictionary *userInfo0 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:duc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDinnerTableBadge
                                                        object:nil
                                                      userInfo:userInfo0];
    
    NSDictionary *userInfo1 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:puc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdatePreorderOrderNotifNum
                                                        object:nil
                                                      userInfo:userInfo1];
    
    NSDictionary *userInfo2 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:tuc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateTakeoutOrderNotifNum
                                                        object:nil
                                                      userInfo:userInfo2];
    
    NSDictionary *userInfo3 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:muc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateCallServiceNotifNum
                                                        object:nil
                                                      userInfo:userInfo3];
    
    NSDictionary *userInfo4 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:ruc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateTakeoutRemindersNotifNum
                                                        object:nil
                                                      userInfo:userInfo4];
    
    int badge = duc + puc + tuc + muc + ruc;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
}

/*如果推送的订单和正在查看的订单是同一个订单,则要刷新正在查看的订单*/
- (void)updateDetailViewWhenPush
{
    if (detail.isShowingView) {
        if (pushOrderId == selectedOrderId) {
            for (NSDictionary *dict in orderMsgArray) {
                int orderId = [[dict objectForKey:@"orderId"] integerValue];
                if (selectedOrderId == orderId) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTakeoutDetailViewWhenPush
                                                                        object:nil
                                                                      userInfo:dict];
                    
                    break;
                }
            }
        } else {
            [self restoreListViewAfterRefresh];
        }
    }
    pushOrderId = -1;
}

// 刷新UITableView后，选中的行还要变回选中状态
- (void)restoreListViewAfterRefresh
{
    int k = 0;
    for (NSDictionary *dict in orderMsgArray) {
        int orderId = (int)[[dict objectForKey:@"orderId"] integerValue];
        if (selectedOrderId == orderId) {
            [orderMessagesTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:k inSection:kTableViewOnlyOneSection]
                                                animated:YES
                                          scrollPosition:UITableViewScrollPositionNone];
            
            break;
        }
        k++;
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kMoreActionSheetTag: {
            [self gotoTakeOutRuleView:buttonIndex];
            break;
        }
        case kTimerActionSheetTag: {
            [self selectPauseTime:buttonIndex];
            break;
        }
            
        case kStartTimeActionSheetTag: {
            // 确定
            if (0 == buttonIndex) {
                UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:kStartTimeDatePickerTag];
                NSString *dateStr = [NSString dateToNSString:datePicker.date withFormat:kDateFirstFormat];
                
                NSComparisonResult result = [dateStr compare:self.endDate.text];
                if (result > NSOrderedSame && ![NSString strIsEmpty:self.endDate.text]) {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                self.startDate.text = dateStr;
                
                if (![NSString strIsEmpty:self.startDate.text] && ![NSString strIsEmpty:self.endDate.text]) {
                    
                    // 带上手机号码条件
                    self.mobileSearchNumber = self.searchTextfield.text;
                    
                    // 联网查询
                    [self getTakeoutInfoData:1 withAnimated:YES];
                }
            }
            
            break;
        }
        case kEndTimeActionSheetTag: {
            // 确定
            if (0 == buttonIndex) {
                UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:kEndTimeDatePickerTag];
                NSString *dateStr = [NSString dateToNSString:datePicker.date withFormat:kDateFirstFormat];
                
                NSComparisonResult result = [self.startDate.text compare:dateStr];
                if (result > NSOrderedSame && ![NSString strIsEmpty:self.startDate.text]) {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                
                self.endDate.text = dateStr;
                if (![NSString strIsEmpty:self.startDate.text] && ![NSString strIsEmpty:self.endDate.text]){
                    // 带上手机号码条件
                    self.mobileSearchNumber = self.searchTextfield.text;
                    
                    // 联网查询
                    [self getTakeoutInfoData:1 withAnimated:YES];
                }
            }
            
            break;
        }
            
        case kStateActionSheetTag: {
            if (buttonIndex >= 0 && buttonIndex < statusArray.count) {
                self.stateLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
                
                if (statusSelectedIndex != buttonIndex) {
                    // 带上手机号码条件
                    self.mobileSearchNumber = self.searchTextfield.text;
                    
                    statusSelectedIndex = buttonIndex;
                    [self getTakeoutInfoData:1 withAnimated:YES];
                }
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (actionSheet.tag == kStateActionSheetTag) {
        self.stateImageview.image = [UIImage imageNamed:@"order_shopUpArrow"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kStateActionSheetTag) {
        self.stateImageview.image = [UIImage imageNamed:@"order_shopDownArrow"];
    }
}

- (void)gotoTakeOutRuleView:(NSInteger)btnIndex
{
    // 外卖送餐方式 0送餐上门, 1自取
    int deliveryType = 0;
    // 点击编辑按钮
    switch (btnIndex) {
        case 0: {
            // 外卖设置
            deliveryType = (deliveryOpenFlag) ? 0 : 1;
            break;
        }
        case 1: {
            deliveryType = 1;
            break;
        }
        default: {
            return;
        }
    }
    // 切换到相应的编辑状态下的UI
    isInSubView_ = YES;
    self.telTakeoutButton.hidden = YES;
    self.tableViewBgImageView.hidden = YES;
    self.pauseButton.hidden = YES;
    self.editButton.hidden = YES;
    self.subview.hidden = YES;
    
    
    // 收起订单详细视图
    [detail dismissView];
    selectedOrderId = -1;
    if (selectedRowIndex >= 0) {
        [orderMessagesTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRowIndex inSection:0] animated:YES];
        selectedRowIndex = -1;
    }
    
    if (ruleTakeoutSettingCtrl == nil) {
        ruleTakeoutSettingCtrl = [[RuleTakeoutSettingViewController alloc] init];
        ruleTakeoutSettingCtrl.delegate = self;
    }
    ruleTakeoutSettingCtrl.deliveryType = deliveryType;
    [ruleTakeoutSettingCtrl showInView:self.view];
}

// 选择定时时间
- (void)selectPauseTime:(NSInteger)btnIndex
{
    int startTime = 0;
    switch (btnIndex) {
        case 0: {
            // 外卖设置
            startTime = kStartTime1ForPause * kSecondForPerMinute;
            break;
        }
        case 1: {
            startTime = kStartTime2ForPause * kSecondForPerMinute;
            break;
        }
        case 2: {
            startTime = kStartTime3ForPause * kSecondForPerMinute;
            break;
        }
        default: {
            return;
        }
    }
    [self pauseTakeOut:startTime];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kTimerAlertViewTag == alertView.tag) {
        switch (buttonIndex) {
            case 0: {
                [self resumeTakeOut:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Data Source Loading Methods

- (void)doneLoadingTableViewData
{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:orderMessagesTableview];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(doneLoadingTableViewData)
                                   userInfo:nil
                                    repeats:NO];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.searchTextfield.text = self.mobileSearchNumber;
    
    currentPageIndex = 1;
    [self getTakeoutInfoData:1 withAnimated:NO];
}

-(void)egoRefreshTableHeaderDidTriggerLoadMore
{
    if (currentPageIndex>0 && currentPageIndex<totalPage) {
        int page = currentPageIndex + 1;
        if (page <= totalPage) {
            [loadMoreOrdersCell startLoading:kLoc(@"load_more_order_message_wait")];
            [self getTakeoutInfoData:page withAnimated:NO];
        }
    }
    if (currentPageIndex == totalPage) {
        [loadMoreOrdersCell loadTextWithOutData:kLoc(@"no_more_order_message")];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
    TakeOutTableViewCell *cell = (TakeOutTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TakeOutTableViewCell" owner:self options:nil] lastObject];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    int row = indexPath.row;
    if (row<[orderMsgArray count]) {
        [cell updateOrderMsgInfo:[orderMsgArray objectAtIndex:row]];
    } else {
        if (loadMoreOrdersCell == nil) {
            loadMoreOrdersCell = [[[NSBundle mainBundle] loadNibNamed:@"OrderListLoadMoreCell"
                                                                owner:self
                                                              options:nil] lastObject];
            loadMoreOrdersCell.selectionStyle = UITableViewCellSelectionStyleGray;
            [loadMoreOrdersCell loadText:kLoc(@"load_more_orders_message")];
        }
        return loadMoreOrdersCell;
    }
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio
{
    if (currentPageIndex < totalPage) {
        return [orderMsgArray count]+1;
    } else {
        return [orderMsgArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [orderMsgArray count])
    {
        UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 647, 30)];
        addressLabel.numberOfLines = 0;
        addressLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        
        NSString *address = [NSString stringWithFormat:@"%@：",kLoc(@"address")];
        
        addressLabel.text = [NSString stringWithFormat:@"%@%@",
                             address,
                             [[orderMsgArray objectAtIndex:indexPath.row] objectForKey:@"address"]];
        int addressHeight = [addressLabel adjustLabelHeight];
        if (addressHeight < 30)
        {
            return 106;
        }
        else
        {
            return 106 + addressHeight - 25;
        }
    }
    else
    {
        return 85;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == [orderMsgArray count]) {
        int viewHeight = 100;
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 808, viewHeight)];
        aView.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 750, viewHeight - 40)];
        label1.numberOfLines = 2;
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = UITextAlignmentCenter;
        label1.font = [UIFont boldSystemFontOfSize:20];
        label1.textColor = [UIColor blackColor];
        label1.text = kLoc(@"no_records");
        [aView addSubview:label1];
        
        return aView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == [orderMsgArray count]) {
        return 100;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果正在搜索不让用户点击查看订单详细
	if ([self.searchTextfield isFirstResponder]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    int row = indexPath.row;
    if (row < [orderMsgArray count]) {
        // 点击外卖行，显示详情
        if (selectedRowIndex != row) {
            NSDictionary *detailDict = [orderMsgArray objectAtIndex:row];
            selectedOrderId = [[detailDict objectForKey:@"orderId"] intValue];
            
            if (detail == nil) {
                detail = [[OrderMessageDetailViewController alloc] init];
                detail.delegate = self;
            }
            detail.tag = row;
            detail.orderType = 2;
            detail.reasonOptionsArray = reasonOptionsArray;
            detail.reminderOptionsArray = reminderOptionsArray;
            [detail showInView:self.view];
            [detail updateInfo:detailDict];
            
            selectedRowIndex = row;
        }
    } else {
        // 点击最后一行（显示更多）
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        int page = currentPageIndex + 1;
        if (page <= totalPage) {
            [loadMoreOrdersCell startLoading:kLoc(@"load_more_order_message_wait")];
            [self getTakeoutInfoData:page withAnimated:NO];
        }
        if (currentPageIndex == totalPage && row == [orderMsgArray count]) {
            [loadMoreOrdersCell loadTextWithOutData:kLoc(@"no_more_order_message")];
        }
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 收起详细页面
    [detail dismissView];
    selectedOrderId = -1;
    if (selectedRowIndex >= 0) {
        [orderMessagesTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRowIndex inSection:0] animated:YES];
        selectedRowIndex = -1;
    }
    
    if (self.startDate == textField) {
        
        [self.searchTextfield resignFirstResponder];
        
        NSDate *startDate = [NSDate date];
        NSString *startDateStr = self.startDate.text;
        
        if ([startDateStr length] > 0) {
            startDate = [startDateStr stringToNSDateWithFormat:kDateFirstFormat];
        }
        
        [self showStartTimeActionSheet:kStartTimeActionSheetTag
                    withDatePickerDate:startDate
                     withDatePickerTag:kStartTimeDatePickerTag
                              withRect:self.startDate.frame];
        
        return NO;
    } else if (self.endDate == textField) {
        
        [self.searchTextfield resignFirstResponder];
        
        NSDate *endDate = [NSDate date];
        NSString *endDateStr = [NSString getStrWithoutWhitespace:self.endDate.text];
        if (![NSString strIsEmpty:endDateStr]) {
            endDate = [endDateStr stringToNSDateWithFormat:kDateFirstFormat];
        }
        [self showStartTimeActionSheet:kEndTimeActionSheetTag
                    withDatePickerDate:endDate
                     withDatePickerTag:kEndTimeDatePickerTag
                              withRect:self.endDate.frame];
        
        return NO;
    }
    
    // 右边的搜索
    orderMessagesTableview.scrollEnabled = NO;
    
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    orderMessagesTableview.scrollEnabled = YES;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (self.searchTextfield == textField) {
        NSString *keywordWithoutSpace = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.mobileSearchNumber = keywordWithoutSpace;
        currentPageIndex = 1;
        [self getTakeoutInfoData:1 withAnimated:YES];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.searchTextfield == textField) {
        if ((![NSString isValidateNumber:string]) || range.location >= kPhoneNumberLength) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark RuleTakeoutSettingViewControllerDelegate

-(void)RuleTakeoutSettingViewController:(RuleTakeoutSettingViewController*)ctrl didDismissView:(BOOL)flag
{
    isInSubView_ = NO;
    self.telTakeoutButton.hidden = NO;
    self.tableViewBgImageView.hidden = NO;
    self.pauseButton.hidden = NO;
    self.editButton.hidden = NO;
    
    [self updateSettingBtn:ctrl.settingBtnDict];
    [self updateTakeOutAuthority];
    //ruleTakeoutSettingCtrl = nil;
}


#pragma mark OrderMessageDetailViewControllerDelegate

-(void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)detailController didChecked:(BOOL)isChecked newOrderStatus:(int)status
{
    for (int i = 0; i < [orderMsgArray count]; i ++) {
        NSMutableDictionary *msg = [[NSMutableDictionary alloc]initWithDictionary:[orderMsgArray objectAtIndex:i]];
        int orderId = [[msg objectForKey:@"orderId"]integerValue];
        if (detailController.orderId == orderId) {
            [msg setObject:[NSNumber numberWithInt:1] forKey:@"isChecked"];
            [msg setObject:[NSNumber numberWithInt:status] forKey:@"status"];
            [orderMsgArray replaceObjectAtIndex:i withObject:msg];
            [orderMessagesTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [orderMessagesTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            break;
        }
    }
    
    if (isChecked) {
        tuc--;
        if (tuc < 0) {
            tuc = 0;
        }
        
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:tuc], @"num", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateTakeoutOrderNotifNum object:nil userInfo:userInfo];
        
        int badge = duc + puc + tuc + muc + ruc;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    }
}

- (void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)detailController didUpdatedInfo:(NSDictionary*)info
{
    for (int i = 0; i < [orderMsgArray count]; i ++) {
        NSMutableDictionary *msg = [[NSMutableDictionary alloc] initWithDictionary:[orderMsgArray objectAtIndex:i]];
        int orderId = [[msg objectForKey:@"orderId"] intValue];
        if (detailController.orderId == orderId) {
            if ([[msg objectForKey:@"reminderStatus"] intValue] == 1) {
                // 之前是催单状态
                if ([[info objectForKey:@"reminderStatus"] intValue] != 1) {
                    // 现在不是催单状态，说明改变的催单状态，更新badge
                    ruc--;
                    [self updateBadge];
                }
            }
            [orderMsgArray replaceObjectAtIndex:i withObject:info];
            [orderMessagesTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [orderMessagesTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            break;
        }
    }
}

- (void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)picker didDismissView:(UIButton*)sender
{
    [detail dismissView];
    selectedOrderId = -1;
    
    for (int i = 0; i < [orderMsgArray count]; i ++) {
        NSMutableDictionary *msg = [[NSMutableDictionary alloc]initWithDictionary:[orderMsgArray objectAtIndex:i]];
        int orderId = [[msg objectForKey:@"orderId"]integerValue];
        if (picker.orderId == orderId) {
            [orderMessagesTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            
            break;
        }
    }
    if (selectedRowIndex>=0) {
        selectedRowIndex = -1;
    }
}

#pragma mark - StaffSortStyleViewDelegate

- (void)takeOutShopListView:(TakeOutShopListView *)shopView withSelectedShop:(NSString *)shopName
{
    // 带上手机号码条件
    self.mobileSearchNumber = self.searchTextfield.text;
    
    self.shopLabel.text = shopName;
    branchId = shopView.branchId;
    [self getTakeoutInfoData:currentPageIndex withAnimated:YES];
    [self customPopoverTouchView:nil touchesBegan:nil withEvent:nil];
}

#pragma mark - CustomPopoverTouchViewDelegate

- (void)customPopoverTouchView:(UIView *)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:customTouchView];
    CGRect touchRect = CGRectMake(kTakeOutShopListViewOrigin.x, kTakeOutShopListViewOrigin.y, shopListView.frame.size.width, shopListView.frame.size.height);
    if (!CGRectContainsPoint(touchRect, touchPoint)) {
        [shopListView dismissViewWithAnimated:YES];
        [customTouchView removeFromSuperview];
        OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
        NSArray *shopArray = [offlineMgr fetchBranchShopData];
        if ([shopArray count]) {
            self.shopArrowImageView.image = LoadImageWithPNGType(@"order_shopDownArrow");
        }
    }
}

#pragma mark - TakeoutByPhoneViewControllerDelegate methods

- (void)takeoutByPhoneViewController:(TakeoutByPhoneViewController *)viewController
              dismissWithDataChanged:(BOOL)isDataChanged
{
    // 移除
    [viewController dismissViewControllerWithAnimated:YES];
    takeoutByTelViewController_ = nil;
    
    // 删除旧电话外卖数据
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kTakeoutByPhoneDishesListKey];
    [userDefaults removeObjectForKey:kTakeoutByPhoneUserInfoKey];
    [userDefaults synchronize];
    
    // 显示UI
    isInSubView_ = NO;
    self.telTakeoutButton.hidden = NO;
    self.tableViewBgImageView.hidden = NO;
    self.pauseButton.hidden = NO;
    self.editButton.hidden = NO;
    self.subview.hidden = NO;
    
    if (isDataChanged) {
        // 刷新数据
        self.orderMessagesTableview.contentOffset = CGPointZero;
        self.searchTextfield.text = self.mobileSearchNumber;
        
        currentPageIndex = 1;
        [self getTakeoutInfoData:1 withAnimated:NO];
    }
}

#pragma mark - JsonPickerDelegate methods

- (void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    NSDictionary *dataDict = [dict objectForKey:@"data"];
#ifdef DEBUG
//    NSString *jsonStr = [self DataTOjsonString:dataDict];
//    NSLog(@">>>%@",jsonStr);
#endif
    // 获取外卖信息
    if (kJsonPickerFirstTag == picker.tag) {
        switch (responseStatus) {
            case 200: {
                int newPage = [[dataDict objectForKey:@"currentPage"] intValue];
                if (newPage == currentPageIndex) {
                    [orderMsgArray removeAllObjects];
                }
                currentPageIndex = newPage;
                totalPage = [[dataDict objectForKey:@"totalPage"] intValue];
                totalRow = [[dataDict objectForKey:@"totalRow"] intValue];
                
                NSDictionary *unreadInfo = [dataDict objectForKey:@"data"];
                duc = [[unreadInfo objectForKey:@"duc"] intValue];
                puc = [[unreadInfo objectForKey:@"puc"] intValue];
                tuc = [[unreadInfo objectForKey:@"tuc"] intValue];
                muc = [[unreadInfo objectForKey:@"muc"] intValue];
                ruc = [[unreadInfo objectForKey:@"ruc"] intValue];
                
                [reasonOptionsArray removeAllObjects];
                [reasonOptionsArray addObjectsFromArray:[dataDict objectForKey:@"cancelReasonOptions"]];
                [reminderOptionsArray removeAllObjects];
                [reminderOptionsArray addObjectsFromArray:[dataDict objectForKey:@"reminderStatusList"]];
                [orderMsgArray addObjectsFromArray:[dataDict objectForKey:@"orderList"]];
                
                if (statusArray) {
                    [statusArray removeAllObjects];
                }
                [statusArray addObjectsFromArray:[dataDict objectForKey:@"statusList"]];
                phoneOrderTypeDefault_ = [[dataDict objectForKey:@"phoneOrderTypeDefault"]boolValue];
                phoneOrderInputTypeDefault_ = [[dataDict objectForKey:@"phoneOrderInputTypeDefault"]boolValue];
                
                if (isStatusAll && statusArray.count > 0) {
                    // 状态默认
                    self.stateLabel.text = [statusArray[0] objectForKey:@"name"];
                    statusSelectedIndex = 0;
                    isStatusAll = NO;
                }
                
                self.stateImageview.hidden = statusArray.count?NO:YES;
                
                
                [self updateSettingBtn:[dataDict objectForKey:@"settingButtons"]];
                [loadMoreOrdersCell stopLoading:kLoc(@"load_more_orders_message")];
                [orderMessagesTableview reloadData];
                [self updateBadge];
                [self updateDetailViewWhenPush];
                
                break;
            }
                
            case 201: {
                // 数据为空，你访问的订单不存在
                [self updateSettingBtn:[dataDict objectForKey:@"settingButtons"]];
                
                if (statusArray) {
                    [statusArray removeAllObjects];
                }
                [statusArray addObjectsFromArray:[dataDict objectForKey:@"statusList"]];
                
                if (isStatusAll && statusArray.count > 0) {
                    // 状态默认
                    self.stateLabel.text = [statusArray[0] objectForKey:@"name"];
                    statusSelectedIndex = 0;
                    isStatusAll = NO;
                    
                }
                self.stateImageview.hidden = statusArray.count ? NO : YES;
                
                currentPageIndex = 0;
                totalPage = 0;
                totalRow = 0;
                [orderMsgArray removeAllObjects];
                [orderMessagesTableview reloadData];
                break;
            }
            default: {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                
                break;
            }
        }
    }
    if (kJsonPickerSecondTag == picker.tag) {
        switch (responseStatus) {
            case 200: {
                [self updateSettingBtn:dataDict];
                break;
            }
            case 201: {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                
                [self updateSettingBtn:dataDict];
                break;
            }
            default: {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                
                break;
            }
        }
    }
    
    if (kJsonPickerThirdTag == picker.tag) {
        switch (responseStatus) {
            case 200: {
                [self performSelectorOnMainThread:@selector(endTimer) withObject:nil waitUntilDone:YES];
                break;
            }
            default: {
                if (picker.showActivityIndicator) {
                    [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                }
                
                if (pauseTimeCount <= 0) {
                    [self performSelectorOnMainThread:@selector(endTimer)
                                           withObject:nil
                                        waitUntilDone:YES];
                }
                
                break;
            }
        }
    }
    [self finishLoading];
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    [self finishLoading];
}


// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    [self finishLoading];
}

@end
