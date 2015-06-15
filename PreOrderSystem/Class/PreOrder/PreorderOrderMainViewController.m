//
//  PreOrderMainViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PreorderOrderMainViewController.h"
#import "Constants.h"
#import "MainViewController.h"
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "OrderMessageDetailViewController.h"
#import "PreorderOrderTableViewCell.h"
#import "NsstringAddOn.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "CustomDatePicker.h"
#import "OfflineManager.h"
#import "StaffManagementSuperDataClass.h"
#import "CustomPopoverTouchView.h"
#import "TakeOutShopListView.h"
#import "UIViewController+MJPopupViewController.h"
#import "MainViewController.h"
#import "OrderByPhoneViewController.h"
#import "UITextFieldAddition.h"

#define kMoreActionSheetTag 1000
#define kStateActionSheetTag 1200
#define kStartTimeActionSheetTag 100
#define kEndTimeActionSheetTag 101
#define kStartTimeDatePickerTag 102
#define kEndTimeDatePickerTag 103

#define kPhoneNumberLength 11
@interface PreorderOrderMainViewController ()<CustomPopoverTouchViewDelegate, TakeOutShopListViewDelegate, OrderByPhoneViewControllerDelegate>
{
    TakeOutShopListView *shopListView;
    CustomPopoverTouchView *customTouchView;
    NSInteger branchId;//连锁店id
}

- (IBAction)editButtonPressed:(UIButton*)sender;
- (IBAction)shopBtnPressed:(UIButton *)sender;
//获取订座信息
-(void)getPreorderInfoData:(int)page withAnimated:(BOOL)animated;
- (void)addPullDownReFresh;

@end

@implementation PreorderOrderMainViewController

@synthesize isShowing;
@synthesize editButton;
@synthesize orderMessagesTableview;
@synthesize subview;
@synthesize tableViewBgImageView;

#pragma mark -
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
    
    // 添加关闭按钮
    [self.searchTextfield bindCloseButton];
    
//    statusArray = [[NSMutableArray alloc] init];
//    int i = statusArray[100];
    selectedOrderId = -1;
    pushOrderId = -1;
    selectedRowIndex = -1;
    currentPageIndex = 1;
    totalPage = 0;
    totalRow = 0;
    isStatusAll = YES;
    orderMsgArray = [[NSMutableArray alloc] init];
    reasonOptionsArray = [[NSMutableArray alloc]init];
    statusArray = [[NSMutableArray alloc]init];
    
    // 设置日期搜索默认时间
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSDictionary *dict = [offlineMgr fetchDefaultOrderFilterDateData];
    
    if (dict)// 日期搜索默认时间
    {
        NSDictionary *bookDict = [dict objectForKey:@"booking"] ;
        
        if (bookDict)
        {
            self.startDate.text = [bookDict objectForKey:@"start"] ;
            self.endDate.text = [bookDict objectForKey:@"end"] ;
        }
    }
    
    [self addPictureToView];
    [self addLocalizedString];
    [self updatePreOrderAuthority];
    NSArray *shopArray = [offlineMgr fetchBranchShopData];
    if ([shopArray count])
    {
        NSString *shopName = [[shopArray firstObject] objectForKey:@"name"];
        self.shopLabel.text = shopName;
        self.shopLabel.hidden = self.shopButton.hidden = self.shopArrowImageView.hidden = NO;
        self.searchBgImageView.image = LoadImageWithPNGType(@"order_searchBg");
        self.shopArrowImageView.image = LoadImageWithPNGType(@"order_shopDownArrow");
    }
    else
    {
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
    
    if (!self.subview.hidden)
    {
        [self registerForNotifications];
        [self addPullDownReFresh];
        [self getPreorderInfoData:currentPageIndex withAnimated:YES];
    }
    
    self.mealTimeButton.selected = YES;//默认送达时间排序
    [self updateQueueStatus];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self unregisterFromNotifications];
    orderMsgArray = nil;
    customPicker = nil;
    timeSearchArray = nil;
    rulePreorderSettingCtrl = nil;
    detail = nil;
    _refreshHeaderView = nil;
    loadMoreOrdersCell = nil;
    jsonPicker = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"order_seats") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
    isShowing = YES;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self viewDidUnload];
        [self setView:nil];
    }
}

-(void)dealloc
{
    [self unregisterFromNotifications];
}

#pragma mark PUBLIC METHODS

-(void)showInView:(UIView*)aView
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




- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	[self.view removeFromSuperview];
}

-(void)dismissView
{
    [detail dismissView];
    selectedOrderId = -1;
    [rulePreorderSettingCtrl dismissView];
    
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



#pragma mark PRIVATE METHODS
//显示时间ActionSheet
- (void)showStartTimeActionSheet:(NSInteger)actionSheetTag withDatePickerDate:(NSDate *)pickerDate withDatePickerTag:(NSInteger)datePickerTag withRect:(CGRect)showRect
{
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
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

- (void)addLocalizedString
{
    [self.orderByPhoneButton setTitle:kLoc(@"order_seat_by_phone")
                             forState:UIControlStateNormal];
    self.nameLabel.text = kLoc(@"name");
    self.numberLabel.text = kLoc(@"people_number");
    self.phoneLabel.text = kLoc(@"phone_number");
    self.mealTimesLabel.text = kLoc(@"take_seat_time");
    self.orderTimeLabel.text = kLoc(@"order_time");
    self.stateLabel.text = kLoc(@"status");
    self.searchTextfield.placeholder = kLoc(@"phone_number");
}

- (void)addPictureToView
{
    tableViewBgImageView.image = [UIImage imageFromMainBundleFile:@"order_frameBg.png"];
    [self.orderByPhoneButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_pauseBg.png"]
                                       forState:UIControlStateNormal];
}

//下拉刷新
- (void)addPullDownReFresh
{
    _reloading = NO;
    if (!_refreshHeaderView)
    {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - orderMessagesTableview.bounds.size.height, self.view.frame.size.width, orderMessagesTableview.bounds.size.height)];
		_refreshHeaderView.delegate = self;
        _refreshHeaderView.backgroundColor = [UIColor clearColor];
		[orderMessagesTableview addSubview:_refreshHeaderView];
	}
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void)updatePreOrderAuthority
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    for (NSDictionary *authDict in authorityArray)
    {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfBookingIndexStr])
        {
            for (StaffManagementSubAuthDataClass *subAuth in authClass.childrenArray)
            {
                if ([subAuth.indexStr isEqualToString:@"setting"])
                {
                    self.editButton.enabled = subAuth.open;
                }
                else if ([subAuth.indexStr isEqualToString:@"main"])
                {
                    self.subview.hidden = !subAuth.open;
                }
            }
            break;
        }
    }
}

- (void)updateQueueStatus
{
    self.mealTimesLabel.textColor = [UIColor blackColor];
    self.orderTimeLabel.textColor = [UIColor blackColor];
    self.stateImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
    
    if (self.mealTimeButton.selected)
    {
        self.mealTimesLabel.textColor = [UIColor orangeColor];
    }
    else if (self.orderTimeButton.selected)
    {
        self.orderTimeLabel.textColor = [UIColor orangeColor];
    }
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
    [self getPreorderInfoData:1 withAnimated:YES];
}

- (IBAction)orderTimeBtnClick:(UIButton *)sender
{
    if (sender.selected) return;
    
    [self.searchTextfield resignFirstResponder];
    // 带上手机号码条件
    self.mobileSearchNumber = self.searchTextfield.text;
    
    sender.selected = !sender.selected;
    self.mealTimeButton.selected = NO;
    [self updateQueueStatus];
    [self getPreorderInfoData:1 withAnimated:YES];
}

- (IBAction)stateBtnClick:(UIButton *)sender
{
    [self.searchTextfield resignFirstResponder];
    
    sender.selected = !sender.selected;
    if (statusArray.count == 0) return;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = kStateActionSheetTag;
    
    for (int i = 0; i < statusArray.count; i++)
    {
        NSString *string = [NSString stringWithFormat:@"%@" ,kLoc([statusArray[i] objectForKey:@"name"])];
        [actionSheet addButtonWithTitle:string];
    }
    
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:self.stateVirtualLabel.frame inView:self.subview animated:YES];
    }
}

-(IBAction)editButtonPressed:(UIButton*)sender
{
    [self.searchTextfield resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:kLoc(@"order_seat_setting"), nil];
    if (kIsiPhone) {
        [actionSheet addButtonWithTitle:kLoc(@"cancel")];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    }
    actionSheet.tag = kMoreActionSheetTag;
    
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
    }
    
}

//选择连锁店按钮
- (IBAction)shopBtnPressed:(UIButton *)sender
{
    [self.searchTextfield resignFirstResponder];
    
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *shopArray = [offlineMgr fetchBranchShopData];
    if ([shopArray count])
    {
        self.shopArrowImageView.image = LoadImageWithPNGType(@"order_shopUpArrow");
        
        MainViewController *mainVC = [MainViewController getMianViewShareInstance];
        if (!customTouchView)
        {
            customTouchView = [[CustomPopoverTouchView alloc] initWithFrame:mainVC.view.frame];
        }
        customTouchView.delegate = self;
        [mainVC.view addSubview:customTouchView];
        
        if (!shopListView)
        {
            shopListView = [[TakeOutShopListView alloc] initWithFrame:CGRectZero];
        }
        shopListView.delegate = self;
        [shopListView showInView:mainVC.view withOriginPoint:kPreOrderShopListViewOrigin withAnimated:YES];
        [shopListView updateTakeOutShopListView:shopArray];
    }
}

/**
 * @brief   电话订座按钮事件。
 *
 */
- (IBAction)orderByPhoneButtonAction:(id)sender
{
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"booking/dateList"];
}

#pragma mark - Notifications

//注册Notification
- (void)registerForNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(didUpdatedOrderList) name:kUpdatedPreorderOrderListWhenEnterForeground object:nil];
    [nc addObserver:self selector:@selector(updatedOrderListWhenPush:) name:kUpdatePreOrderListWhenPush object:nil];
    [nc addObserver:self selector:@selector(shouldUpdatedOrderListWithLocalOrder) name:kShouldUpdatePreorderOrderListWithLocalOrder object:nil];
}

//撤消Notification
- (void)unregisterFromNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updatedOrderListWhenPush:(NSNotification *)notify
{
    pushOrderId = (int)[[notify.userInfo objectForKey:@"oid"]integerValue];
    [self getPreorderInfoData:1 withAnimated:NO];
}

-(void)shouldUpdatedOrderListWithLocalOrder
{
    [self getPreorderInfoData:1 withAnimated:NO];
}

-(void)didUpdatedOrderList
{
    [self getPreorderInfoData:1 withAnimated:NO];
}

/*如果推送的订单和正在查看的订单是同一个订单,则要刷新正在查看的订单*/
- (void)updateDetailViewWhenPush
{
    if (detail.isShowingView)
    {
        if (pushOrderId == selectedOrderId)
        {
            for (NSDictionary *dict in orderMsgArray)
            {
                NSInteger orderId = [[dict objectForKey:@"orderId"] integerValue];
                if (selectedOrderId == orderId)
                {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kUpdatePreOrderDetailViewWhenPush object:nil userInfo:dict];
                    
                    break;
                }
            }
        }
        else
        {
            [self restoreListViewAfterRefresh];
        }
    }
    pushOrderId = -1;
}

//刷新UITableView后，选中的行还要变回选中状态
- (void)restoreListViewAfterRefresh
{
    int k = 0;
    for (NSDictionary *dict in orderMsgArray)
    {
        NSInteger orderId = [[dict objectForKey:@"orderId"] integerValue];
        if (selectedOrderId == orderId)
        {
            [orderMessagesTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:k inSection:kTableViewOnlyOneSection] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            break;
        }
        k++;
    }
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

#pragma mark Network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

//获取订座订单列表
-(void)getPreorderInfoData:(int)page withAnimated:(BOOL)animated
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
    [postData setObject:[NSNumber numberWithInt:1] forKey:@"orderType"];
    [postData setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [postData setObject:[NSNumber numberWithInt:(int)branchId] forKey:@"branchId"];
    
    // 关键字
    if ([self.mobileSearchNumber length] > 0) {
        [postData setObject:self.mobileSearchNumber forKey:@"keyword"];
    }
    self.searchTextfield.text = self.mobileSearchNumber;
    
    // 日期
    [postData setObject:self.startDate.text forKey:@"startDate"];
    [postData setObject:self.endDate.text forKey:@"endDate"];
    
    // 送达时间 or 下单时间
    if (self.mealTimeButton.selected) {
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
    [jsonPicker postData:postData withBaseRequest:@"booking/orderlist"];
}

- (int)textTransforNumber:(NSString *)levelStr
{
    int level = 0;
    if ([levelStr isEqualToString:kLoc(@"noon")])
    {
        level = 0;
    }
    else if ([levelStr isEqualToString:kLoc(@"evening")])
    {
        level = 1;
    }
    else
    {
        level = 2;
    }
    return level;
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (kMoreActionSheetTag == actionSheet.tag) {
        if (0 == buttonIndex) {
            // 订座设置
            // 切换到相应的编辑状态下的UI
            self.tableViewBgImageView.hidden = YES;
            self.orderByPhoneButton.hidden = YES;
            self.editButton.hidden = YES;
            self.subview.hidden = YES;
            
            // 收起订单详细视图
            [detail dismissView];
            selectedOrderId = -1;
            if (selectedRowIndex>=0)
            {
                [orderMessagesTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRowIndex inSection:0] animated:YES];
                selectedRowIndex = -1;
            }
            
            if (rulePreorderSettingCtrl==nil) {
                rulePreorderSettingCtrl = [[RulePreorderSettingViewController alloc] init];
                rulePreorderSettingCtrl.delegate = self;
            }
            [rulePreorderSettingCtrl showInView:self.view];
        }
    } else if(kStateActionSheetTag == actionSheet.tag) {
        if (buttonIndex >= 0 && buttonIndex < statusArray.count) {
            self.stateLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
            
            if (statusSelectedIndex != buttonIndex) {
                
                // 带上手机号码条件
                self.mobileSearchNumber = self.searchTextfield.text;
                
                statusSelectedIndex = buttonIndex;
                [self getPreorderInfoData:1 withAnimated:YES];
            }
        }
    } else if (kStartTimeActionSheetTag == actionSheet.tag) {
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
                [self getPreorderInfoData:1 withAnimated:YES];
            }
        }
        
    } else if (kEndTimeActionSheetTag == actionSheet.tag) {
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
            if (![NSString strIsEmpty:self.startDate.text] && ![NSString strIsEmpty:self.endDate.text]) {
                
                // 带上手机号码条件
                self.mobileSearchNumber = self.searchTextfield.text;
                
                //联网查询
                [self getPreorderInfoData:1 withAnimated:YES];
            }
        }
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (actionSheet.tag == kStateActionSheetTag) {
        self.stateImageView.image = [UIImage imageNamed:@"order_shopUpArrow"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kStateActionSheetTag) {
        self.stateImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


#pragma mark Data Source Loading Methods

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:orderMessagesTableview];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.searchTextfield.text = self.mobileSearchNumber;
    currentPageIndex = 1;
    [self getPreorderInfoData:1 withAnimated:NO];
}


-(void)egoRefreshTableHeaderDidTriggerLoadMore
{
    if (currentPageIndex>0 && currentPageIndex<totalPage)
    {
        int page = currentPageIndex+1;
        if (page<=totalPage)
        {
            [loadMoreOrdersCell startLoading:kLoc(@"load_more_order_message_wait")];
            [self getPreorderInfoData:page withAnimated:NO];
        }
    }
    if (currentPageIndex == totalPage)
    {
        [loadMoreOrdersCell loadTextWithOutData:kLoc(@"no_more_order_message")];
    }
}


- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}


- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark -
#pragma mark UITableViewController datasource & delegate 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = kPreOrderTableViewCellReuseIdentifier;
    PreorderOrderTableViewCell *cell = (PreorderOrderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PreorderOrderTableViewCell" owner:self options:nil] lastObject];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    NSInteger row = indexPath.row;
    if (row<[orderMsgArray count])
    {
        [cell updateOrderMsgInfo:[orderMsgArray objectAtIndex:row]];
    }
    else
    {
        if (loadMoreOrdersCell==nil)
        {
            loadMoreOrdersCell = [[[NSBundle mainBundle] loadNibNamed:@"OrderListLoadMoreCell" owner:self options:nil] lastObject];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (currentPageIndex < totalPage)
    {
        return [orderMsgArray count]+1;
    }
    else
    {
        return [orderMsgArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 85;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == [orderMsgArray count])
    {
        int viewHeight = 100;
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 808, viewHeight)];
        aView.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 748, viewHeight - 40)];
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
    if ([orderMsgArray count]==0)
    {
        return 100;
    }
    else
    {
       return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.searchTextfield isFirstResponder])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    int row = indexPath.row;
    if (row < [orderMsgArray count]) {
        // 点击订单行，显示订单详情
        if (selectedRowIndex != row) {
            NSDictionary *detailDict = [orderMsgArray objectAtIndex:row];
            selectedOrderId = [[detailDict objectForKey:@"orderId"] integerValue];
            if (!detail) {
                detail = [[OrderMessageDetailViewController alloc] init];
                detail.delegate = self;
            }
            detail.tag = row;
            detail.orderType = 1;
            detail.reasonOptionsArray = reasonOptionsArray;
            [detail showInView:self.view];
            [detail updateInfo:detailDict];
            
            selectedRowIndex = row;
        }
    } else {
        // 点击最后一行（显示更多）
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        int page = currentPageIndex+1;
        if (page <= totalPage) {
            [loadMoreOrdersCell startLoading:kLoc(@"load_more_order_message_wait")];
            [self getPreorderInfoData:page withAnimated:NO];
        }
        if (currentPageIndex == totalPage && row == [orderMsgArray count]) {
            [loadMoreOrdersCell loadTextWithOutData:kLoc(@"no_more_order_message")];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //收起详细页面
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
    
    //右边的搜索
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
        [self getPreorderInfoData:1 withAnimated:YES];
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

#pragma mark - RulePreorderSettingViewControllerDelegate

-(void)RulePreorderSettingViewController:(RulePreorderSettingViewController*)ctrl didDismissView:(BOOL)flag
{
    self.tableViewBgImageView.hidden = NO;
    self.orderByPhoneButton.hidden = NO;
    self.editButton.hidden = NO;
    [self updatePreOrderAuthority];
    //rulePreorderSettingCtrl = nil;
}

#pragma mark - OrderByPhoneViewControllerDelegate

- (void)orderByPhoneViewController:(OrderByPhoneViewController *)ctrl withLastestPreOrderData:(NSDictionary *)dict
{
    if (dict) {
        [self handleFirstSuccessfulJsonPicker:dict];
    }
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

#pragma mark -OrderMessageDetailViewControllerDelegate

-(void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)detailController didChecked:(BOOL)isChecked newOrderStatus:(int)status
{
    for (int i = 0; i < [orderMsgArray count]; i ++)
    {
         NSMutableDictionary *msg = [[NSMutableDictionary alloc]initWithDictionary:[orderMsgArray objectAtIndex:i]];
        int orderId = [[msg objectForKey:@"orderId"]integerValue];
        if (detailController.orderId == orderId)
        {
            [msg setObject:[NSNumber numberWithInt:1] forKey:@"isChecked"];
            [msg setObject:[NSNumber numberWithInt:status] forKey:@"status"];
            [orderMsgArray replaceObjectAtIndex:i withObject:msg];
            [orderMessagesTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [orderMessagesTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            break;
        }
    }
    
    //
    if (isChecked)
    {
        puc--;
        if (puc < 0) {
            puc = 0;
        }
        
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:puc], @"num", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdatePreorderOrderNotifNum object:nil userInfo:userInfo];
        
        int badge = duc + puc + tuc + muc + ruc;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    }
}


-(void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)detailController didUpdatedInfo:(NSDictionary*)info
{
    for (int i = 0; i < [orderMsgArray count]; i ++)
    {
        NSMutableDictionary *msg = [[NSMutableDictionary alloc]initWithDictionary:[orderMsgArray objectAtIndex:i]];
        int orderId = [[msg objectForKey:@"orderId"]integerValue];
        if (detailController.orderId == orderId)
        {
            [orderMsgArray replaceObjectAtIndex:i withObject:info];
            [orderMessagesTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [orderMessagesTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            break;
        }
    }
}

-(void)OrderMessageDetailViewController:(OrderMessageDetailViewController*)picker didDismissView:(UIButton*)sender
{
    [detail dismissView];
    selectedOrderId = -1;
    
    for (int i = 0; i < [orderMsgArray count]; i ++)
    {
        NSMutableDictionary *msg = [[NSMutableDictionary alloc]initWithDictionary:[orderMsgArray objectAtIndex:i]];
        int orderId = [[msg objectForKey:@"orderId"]integerValue];
        if (picker.orderId == orderId)
        {
            [orderMessagesTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            
            break;
        }
    }
    if (selectedRowIndex>=0)
    {
        selectedRowIndex = -1;
    }
}

#pragma mark - StaffSortStyleViewDelegate

- (void)takeOutShopListView:(TakeOutShopListView *)shopView withSelectedShop:(NSString *)shopName
{
    if (branchId != shopView.branchId) {
        
        // 带上手机号码条件
        self.mobileSearchNumber = self.searchTextfield.text;
        
        self.shopLabel.text = shopName;
        branchId = shopView.branchId;
        currentPageIndex = 1;
        [self getPreorderInfoData:currentPageIndex withAnimated:YES];
        [self customPopoverTouchView:nil touchesBegan:nil withEvent:nil];
    }
}

#pragma mark - CustomPopoverTouchViewDelegate

- (void)customPopoverTouchView:(UIView *)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:customTouchView];
    CGRect touchRect = CGRectMake(kPreOrderShopListViewOrigin.x, kPreOrderShopListViewOrigin.y, shopListView.frame.size.width, shopListView.frame.size.height);
    if (!CGRectContainsPoint(touchRect, touchPoint))
    {
        [shopListView dismissViewWithAnimated:YES];
        [customTouchView removeFromSuperview];
        OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
        NSArray *shopArray = [offlineMgr fetchBranchShopData];
        if ([shopArray count])
        {
            self.shopArrowImageView.image = LoadImageWithPNGType(@"order_shopDownArrow");
        }
    }
}

#pragma mark JsonPickerDelegate

- (void)handleFirstSuccessfulJsonPicker:(NSDictionary *)dict
{
    int newPage = [[dict objectForKey:@"currentPage"] intValue];
    if (newPage == currentPageIndex)
    {
        [orderMsgArray removeAllObjects];
    }
    [orderMsgArray addObjectsFromArray:[dict objectForKey:@"orderList"]];
    [reasonOptionsArray removeAllObjects];
    [reasonOptionsArray addObjectsFromArray:[dict objectForKey:@"cancelReasonOptions"]];
    
    currentPageIndex = newPage;
    totalPage = [[dict objectForKey:@"totalPage"] intValue];
    totalRow = [[dict objectForKey:@"totalRow"] intValue];
    
    NSDictionary *unreadInfo = [dict objectForKey:@"data"];
    duc = [[unreadInfo objectForKey:@"duc"] intValue];
    puc = [[unreadInfo objectForKey:@"puc"] intValue];
    tuc = [[unreadInfo objectForKey:@"tuc"] intValue];
    muc = [[unreadInfo objectForKey:@"muc"] intValue];
    ruc = [[unreadInfo objectForKey:@"ruc"] intValue];
    
    if (statusArray) {
        [statusArray removeAllObjects];
    }
    [statusArray addObjectsFromArray:[dict objectForKey:@"statusList"]];
    
    if (isStatusAll && statusArray.count > 0) {
        // 状态默认
        self.stateLabel.text = [statusArray[0] objectForKey:@"name"];
        statusSelectedIndex = 0;
        isStatusAll = NO;
    }
    self.stateImageView.hidden = statusArray.count?NO:YES;
    
    [loadMoreOrdersCell stopLoading:kLoc(@"load_more_orders_message")];
    [orderMessagesTableview reloadData];
    [self updateBadge];
    [self updateDetailViewWhenPush];
}

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    NSDictionary *dataDict = [dict objectForKey:@"data"];
    //获取订座信息
    if (kJsonPickerFirstTag == picker.tag)
    {
        switch (responseStatus)
        {
            case 200:
            {
                [self handleFirstSuccessfulJsonPicker:dataDict];
                
                break;
            }
            case 201:
            {
                // 数据为空，你访问的订单不存在
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
                self.stateImageView.hidden = statusArray.count?NO:YES;
                
                currentPageIndex = 0;
                totalPage = 0;
                totalRow = 0;
                [orderMsgArray removeAllObjects];
                [orderMessagesTableview reloadData];
                
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                
                break;
            }
        }
    }
    else if (picker.tag == kJsonPickerSecondTag)
    {
        switch (responseStatus)
        {
            case 200:
            {
                NSArray *array = [dataDict objectForKey:@"dateList"];
                if (array.count > 0)
                {
                    OrderByPhoneViewController *vc = [[OrderByPhoneViewController alloc] initWithNibName:@"OrderByPhoneViewController" bundle:nil];
                    vc.delegate = self;
                    [[MainViewController getMianViewShareInstance] presentPopupViewController:vc animationType:MJPopupViewAnimationSlideBottomBottom];
                    // 缩放视图
                    scaleView(vc.view);
                } else {
                    [PSAlertView showWithMessage:kLoc(@"no_order_time")];
                }
                
                break;
            }
                
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                
                break;
            }
        }
    }
    [self finishLoading];
}

// JSON解释错误时返回
- (void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error{
    [self finishLoading];
}

// 网络连接失败时返回（无网络的情况）
- (void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error{
    [self finishLoading];
}

@end
