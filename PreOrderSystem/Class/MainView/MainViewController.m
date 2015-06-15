//
//  MainViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"
#import "PSAlertView.h"
#import "DiningTableMainViewController.h"
#import "PreorderOrderMainViewController.h"
#import "TakeoutOrdersMainViewController.h"
#import "QueueMainViewController.h"
#import "MoreViewController.h"
#import "CallServiceViewController.h"
#import "MemberMainViewController.h"
#import "OfflineManager.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DishCardMainViewController.h"
#import "StaffManagementSuperDataClass.h"
#import "UIViewController+ShowInView.h"
#import "AppDelegate.h"
#import "OrderMessageDetailViewController.h"
#import "DtMenuCookbookViewController.h"
#import "DtMenuCookbookPackageViewController.h"
#import "DtMenuShoppingCarViewController.h"
#import "TakeoutByPhoneViewController.h"
#import "JsonPicker.h"

@interface MainViewController ()
{
    DiningTableMainViewController *dtMainViewCtrl;
    PreorderOrderMainViewController *preorderMainCtrl;
    TakeoutOrdersMainViewController *takeoutMainCtrl;
    DishCardMainViewController *dishCardCtrl;
    QueueMainViewController *queueMainCtrl;
    CallServiceViewController *callServiceViewCtrl;
    MemberMainViewController *memberVC;
    MoreViewController *moreViewController;
    
    CustomSideBar *dinnerTableSideBar;
    CustomSideBar *takeOutSideBar;
    CustomSideBar *preOrderSideBar;
    CustomSideBar *callServiceSideBar;
    NSMutableArray *leftSideBtnArray;
    
    //当前己选的sidebar的index
    int selectedSidebarIndex;
    UIViewController *currentViewController;
    
    //标记快捷按钮拖动前的坐标.
    CGPoint lastPoint_;
    
    //获取数据的小玩意
    JsonPicker *jsonPicker;;
}

- (void)registerForNotifications;
//撤消监听
- (void)unregisterFromNotifications;
//刷新标题
- (void)updateNavTitleText:(NSNotification*)notif;
- (void)showWhichFunction;

@end

static MainViewController *shareInstance = nil;

@implementation MainViewController


#pragma mark LIFE CYCLE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        shareInstance = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addPictureToBgView];
    [self registerForNotifications];
    [self showWhichFunction];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self creatHotKey];
}

- (void)creatHotKey
{
    //**********悬浮按钮测试****************
    if (!self.shortcutArr)
    {
        self.shortcutArr = [[NSMutableArray alloc]init];
    }
    if (!_assistiveTouchView)
    {
        //暂时屏蔽,按tim意思.
        //_assistiveTouchView = [[AssistiveTouch alloc]initWithFrame:CGRectMake(100, 200, 50, 50) imageName:@"256"];
    }
    _assistiveTouchView.hidden = YES;
   // _assistiveTouchView.hidden = NO;
    [self getHotKeyData];
    _assistiveTouchView.assistiveDelegate = self;
//    NSArray *shortcutNameArr = [NSArray arrayWithObjects:@"沽清",@"外卖",@"取消",@"会员",@"添加",@"菜牌",@"登出",@"历史",@"下班", nil];
//    NSArray *shortcutImgArr = [NSArray arrayWithObjects:@"arrow",@"attachment",@"block",@"bluetooth",@"cube",@"download",@"enter",@"file",@"github" ,nil];
//    self.shortcutArr = [[NSMutableArray alloc]init];
//    for (int i = 0;i < shortcutNameArr.count;i++)
//    {
//        ShortcutDataModel *shot = [[ShortcutDataModel alloc]init];
//        shot.shortcutName = [shortcutNameArr objectAtIndex:i];
//        shot.shortcutImg = [shortcutImgArr objectAtIndex:i];
//        shot.isSelected = NO;
//        shot.shortcutID = [NSString stringWithFormat:@"%d",i];
//        [self.shortcutArr addObject:shot];
//    }
    
    //**********悬浮按钮测试****************
}

/**
 *  从服务器获取到快捷键数据后,创建数据模型
 *
 *  @param arr ("list": [])
 */
- (void)creatShortCutDataModel:(NSArray *)arr
{
    for (NSDictionary *dic in arr)
    {
        ShortcutDataModel *shortData = [[ShortcutDataModel alloc]initWithData:dic];
        [self.shortcutArr addObject:shortData];
    }
    _assistiveTouchView.hidden = NO;
}

- (void)getHotKeyData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = NO;
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"hotkey/getList"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self unregisterFromNotifications];
    dtMainViewCtrl = nil;
    preorderMainCtrl = nil;
    takeoutMainCtrl = nil;
    dishCardCtrl = nil;
    queueMainCtrl = nil;
    callServiceViewCtrl = nil;
    memberVC = nil;
    moreViewController = nil;
    leftSideBtnArray = nil;
#ifdef DEBUG
    NSLog(@"===MainViewController,viewDidUnload===");
#endif
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self viewDidUnload];
        [self setView:nil];
    }
#ifdef DEBUG
    NSLog(@"===MainViewController didReceiveMemoryWarning===");
#endif
}

-(void)dealloc
{
    shareInstance = nil;
    [self unregisterFromNotifications];
#ifdef DEBUG
    NSLog(@"===MainViewController,dealloc===");
#endif
}

- (void)addPictureToBgView
{
    self.sideBarBgImageView.image = [UIImage imageFromMainBundleFile:@"nav_sideBarBottom.png"];
    self.backgrondImageView.image = [UIImage imageFromMainBundleFile:@"nav_background.png"];
}


//显示哪个功能页面，房台、订座、外卖、排队、菜牌、呼叫服务、更多
- (void)showWhichFunction
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    BOOL diningTableAuthority = NO;
    BOOL takeoutAuthority = NO;
    BOOL bookingAuthority = NO;
    BOOL cookBookAuthority = NO;
    BOOL queueAuthority = NO;
    BOOL callServiceAuthority = NO;
    BOOL memberAuthority = NO;
    BOOL moreAuthority = YES;
    
    for (NSDictionary *authDict in authorityArray)
    {
        NSLog(@">>>>%@",authDict);
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfDiningTableIndexStr])
        {
            diningTableAuthority = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfTakeoutIndexStr])
        {
            takeoutAuthority = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfBookingIndexStr])
        {
            bookingAuthority = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfCookbookIndexStr])
        {
            cookBookAuthority = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfQueueIndexStr])
        {
            queueAuthority = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfCallServiceIndexStr])
        {
            callServiceAuthority = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfMemberIndexStr])
        {
            memberAuthority = authClass.open;
            continue;
        }
    }
    
    selectedSidebarIndex = 0;
    leftSideBtnArray = [[NSMutableArray alloc]initWithCapacity:3];
    //左边按钮功能应该显示哪些，有权限显示，没有权限不显示
    //房台
    if (diningTableAuthority)
    {
        CustomSideBar *sideBar = [[CustomSideBar alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        sideBar.delegate = self;
        sideBar.tag = kDiningTableSideBarTag;
        dinnerTableSideBar = sideBar;
        [leftSideBtnArray addObject:sideBar];
    }
    //外卖
    if (takeoutAuthority)
    {
        CustomSideBar *sideBar = [[CustomSideBar alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        sideBar.delegate = self;
        sideBar.tag = kTakeOutSideBarTag;
        takeOutSideBar = sideBar;
        sideBar.bgFlag = YES;
        [leftSideBtnArray addObject:sideBar];
    }
    //订座
    if (bookingAuthority)
    {
        CustomSideBar *sideBar = [[CustomSideBar alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        sideBar.delegate = self;
        sideBar.tag = kPreOrderSideBarTag;
        if (!takeoutAuthority)
        {
            sideBar.bgFlag = YES;
        }
        preOrderSideBar = sideBar;
        [leftSideBtnArray addObject:sideBar];
    }
    //菜牌
    if (cookBookAuthority)
    {
        CustomSideBar *sideBar = [[CustomSideBar alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        sideBar.delegate = self;
        sideBar.tag = kDishCardSideBarTag;
        if (!bookingAuthority && !takeoutAuthority)
        {
            sideBar.bgFlag = YES;
        }
        [leftSideBtnArray addObject:sideBar];
    }
    if (queueAuthority)
    {
        CustomSideBar *sideBar = [[CustomSideBar alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        sideBar.delegate = self;
        sideBar.tag = kQueueSideBarTag;
        if (!bookingAuthority && !takeoutAuthority && !cookBookAuthority)
        {
            sideBar.bgFlag = YES;
        }
        [leftSideBtnArray addObject:sideBar];
    }
    if (callServiceAuthority)
    {
        CustomSideBar *sideBar = [[CustomSideBar alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        sideBar.delegate = self;
        sideBar.tag = kCallServiceSideBarTag;
        callServiceSideBar = sideBar;
        if (!bookingAuthority && !takeoutAuthority && !cookBookAuthority && !queueAuthority)
        {
            sideBar.bgFlag = YES;
        }
        [leftSideBtnArray addObject:sideBar];
    }
    if(memberAuthority)
    {
        CustomSideBar *sideBar = [[CustomSideBar alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        sideBar.delegate = self;
        sideBar.tag = kMemberSideBarTag;
        if (!bookingAuthority && !takeoutAuthority && !cookBookAuthority && !queueAuthority && !callServiceAuthority)
        {
            sideBar.bgFlag = YES;
        }
        [leftSideBtnArray addObject:sideBar];
    }
    if(moreAuthority)
    {
        CustomSideBar *sideBar = [[CustomSideBar alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        sideBar.delegate = self;
        sideBar.tag = kMoreSideBarTag;
        if (!bookingAuthority && !takeoutAuthority && !cookBookAuthority && !queueAuthority && !callServiceAuthority && !memberAuthority)
        {
            sideBar.bgFlag = YES;
        }
        [leftSideBtnArray addObject:sideBar];
    }
    
    UIImageView *firstLineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(2, 20, 135, 2)];
    firstLineImageView.image = [UIImage imageFromMainBundleFile:@"nav_sideBar_line.png"];
    firstLineImageView.backgroundColor = [UIColor clearColor];
    [self.sideBarBgImageView addSubview:firstLineImageView];
    
    //创建leftBtn
    for (int i = 0; i < [leftSideBtnArray count]; i++)
    {
        CustomSideBar *sideBar = [leftSideBtnArray objectAtIndex:i];
        sideBar.frame = CGRectMake(2, i * 65 + 20, 135, 65);
        [self.sideBarBgImageView addSubview:sideBar];
        [sideBar updateViewAfterCreateBar];
        if (sideBar.bgFlag)
        {
            [self sideBarPressed:sideBar];
            //[self initViewControllerByTag:sideBar.tag];
        }
    }
}

/*
- (void)initViewControllerByTag:(int)tag
{
    [self addChildViewControllerToParentViewController:[self getViewController:tag]];
}

- (UIViewController *)getViewController:(int)tag
{
    UIViewController *tempViewController = nil;
    switch (tag)
    {
            //房台信息
        case 1:
        {
            if (!dtMainViewCtrl)
            {
                dtMainViewCtrl = [[DiningTableMainViewController alloc] init];
            }
            tempViewController = dtMainViewCtrl;
            
            break;
        }
            //订座
        case 2:
        {
            if (preorderMainCtrl==nil)
            {
                preorderMainCtrl = [[PreorderOrderMainViewController alloc] init];
            }
            tempViewController = preorderMainCtrl;
            
            break;
        }
            //外卖
        case 3:
        {
            if (takeoutMainCtrl==nil)
            {
                takeoutMainCtrl = [[TakeoutOrdersMainViewController alloc] init];
            }
            tempViewController = takeoutMainCtrl;
            
            break;
        }
        case 4:
        {
            if (!dishCardCtrl)
            {
                dishCardCtrl = [[DishCardMainViewController alloc]initWithNibName:@"DishCardMainViewController" bundle:nil];
            }
            tempViewController = dishCardCtrl;
            
            break;
        }
            //排队
        case 5:
        {
            if (queueMainCtrl==nil)
            {
                queueMainCtrl = [[QueueMainViewController alloc] init];
            }
            tempViewController = queueMainCtrl;
            
            break;
        }
            //呼叫服务
        case 6:
        {
            if (callServiceViewCtrl == nil)
            {
                callServiceViewCtrl = [[CallServiceViewController alloc]init];
            }
            tempViewController = callServiceViewCtrl;
            
            break;
        }
            //更多
        case 7:
        {
            if (moreViewController == nil)
            {
                moreViewController = [[MoreViewController alloc]init];
            }
            tempViewController = moreViewController;
            
            break;
        }
    }
    return tempViewController;
}

- (void)addChildViewControllerToParentViewController:(UIViewController *)childController
{
    [self reSetViewControllerOrigin:kViewControllerOrigin withViewController:childController];
    [self addChildViewController:childController];
    currentViewController = childController;
    [self.view addSubview:currentViewController.view];
}

- (void)reSetViewControllerOrigin:(CGPoint)point withViewController:(UIViewController *)VC
{
    CGRect frame = VC.view.frame;
    frame.origin.x = point.x;
    frame.origin.y = point.y;
    VC.view.frame = frame;
}
 */

+ (MainViewController *)getMianViewShareInstance
{
    return shareInstance;
}

#pragma mark Notification

- (void)registerForNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    //监听Notification(更新标题)
    [nc addObserver:self selector:@selector(updateNavTitleText:) name:kShouldUpdateNavTitle object:nil];
    
    //监听Notification(更新房台未读数目的badge)
    [nc addObserver:self selector:@selector(updateDinnerTableBadge:) name:kUpdateDinnerTableBadge object:nil];
    
    //监听Notification(更新订座订单的badge)
    [nc addObserver:self selector:@selector(updatePreorderOrderNotfiNum:) name:kShouldUpdatePreorderOrderNotifNum object:nil];
    
    //监听Notification(更新外卖订单的badge)
    [nc addObserver:self selector:@selector(updateTakeoutOrderNotfiNum:) name:kShouldUpdateTakeoutOrderNotifNum object:nil];
    
    // 监听Notification(更新外卖催单的badge)
    [nc addObserver:self selector:@selector(updateTakeoutRemindersNotfiNum:)
               name:kShouldUpdateTakeoutRemindersNotifNum
             object:nil];
    
    //监听Notification(更新互动的badge)
    [nc addObserver:self selector:@selector(updateInteractNotifNum:) name:kShouldUpdateCallServiceNotifNum object:nil];
    
    //监听Notification(登出)
    [nc addObserver:self selector:@selector(shouldLogoutAccount) name:kLogoutAccount object:nil];
    
    //监听（多语言更新sideButton标题）
    [nc addObserver:self selector:@selector(updateAllButtonTitleNotify) name:kUpdateForLangChangedNotify object:nil];
}

- (void)unregisterFromNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

//登出 
-(void)shouldLogoutAccount
{
    AccountManager *accountMgr = [AccountManager sharedAccountManager];
    [accountMgr logoutAccount];
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    [offlineMgr clearOfflineAccountInfo];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //[self.navigationController popToRootViewControllerAnimated:YES];
    //强制退出
    abort();
}

//刷新标题
-(void)updateNavTitleText:(NSNotification*)notif
{
    self.navTitleLabel.text = [notif.userInfo objectForKey:@"title"];
}

// 更新房台的badge
- (void)updateDinnerTableBadge:(NSNotification *)notif
{
    int unread = [[notif.userInfo objectForKey:@"num"] intValue];
    int isSelect = [[notif.userInfo objectForKey:@"select"] intValue];
    [dinnerTableSideBar updateSideBadge:unread];

    if (isSelect) {
        // 强制回调
        [self sideBarPressed:dinnerTableSideBar];
    }
}

//更新订座订单的badge
-(void)updatePreorderOrderNotfiNum:(NSNotification*)notif
{
    int unread = [[notif.userInfo objectForKey:@"num"] intValue];
    [preOrderSideBar updateSideBadge:unread];
}

//更新外卖订单的badge
-(void)updateTakeoutOrderNotfiNum:(NSNotification*)notif
{
    int unread = [[notif.userInfo objectForKey:@"num"] intValue];
    [takeOutSideBar updateSideBadge:unread];
}

- (void)updateTakeoutRemindersNotfiNum:(NSNotification *)notification
{
    int reminders = [[notification.userInfo objectForKey:@"num"] intValue];
    [takeOutSideBar updateRemindersBadge:reminders];
}

//更新呼叫服务的badge
-(void)updateInteractNotifNum:(NSNotification*)notif
{
    int unread = [[notif.userInfo objectForKey:@"num"] intValue];
    [callServiceSideBar updateSideBadge:unread];
}

//更新所有title
- (void)updateAllButtonTitleNotify
{
    CustomSideBar *takeoutSidebar;
    for (CustomSideBar *cusButton in leftSideBtnArray)
    {
        [cusButton updateViewAfterCreateBar];
        cusButton.isReload = YES;//语言切换， 每个页面都要重新加载
        
        if (cusButton.tag == kTakeOutSideBarTag)
        {
            takeoutSidebar = cusButton;
        }
    }
    
    [self sideBarPressed:takeoutSidebar];//语言切换后， 回到外卖主界面
}

#pragma mark CustomSideBar delegate
/*
- (void)transitionViewController:(UIViewController *)toVC
{
    [self reSetViewControllerOrigin:kViewControllerOrigin withViewController:toVC];
    [self transitionFromViewController:currentViewController toViewController:toVC duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished){
        if (finished)
        {
            currentViewController = toVC;
        }
    }];
}
 
- (void)sideBarPressed:(CustomSideBar *)sender
{
    if (sender.tag<=7)
    {
        //更新到新的页面
        if (selectedSidebarIndex != sender.tag)
        {
            UIViewController *selectVC = [self getViewController:sender.tag];
            NSArray *vcArray = self.childViewControllers;
            int tempCount = [vcArray count];
            for (int k = 0; k < tempCount; k++)
            {
                UIViewController *tempVC = [vcArray objectAtIndex:k];
                if (selectVC != tempVC)
                {
                    [self addChildViewController:selectVC];
                }
            }
            [self transitionViewController:selectVC];
            selectedSidebarIndex = sender.tag;
            
            for (int i = 0; i < [leftSideBtnArray count]; i ++)
            {
                CustomSideBar *tempSideBar = [leftSideBtnArray objectAtIndex:i];
                if (selectedSidebarIndex == tempSideBar.tag)
                {
                     tempSideBar.bgFlag = YES;
                }
                else
                {
                     tempSideBar.bgFlag = NO;
                }
                [tempSideBar updateViewAfterCreateBar];
            }
        }
    }
}
*/

- (void)sideBarPressed:(CustomSideBar *)sender
{
    if (sender.tag <= kMoreSideBarTag)
    {
        //更新到新的页面
        if (selectedSidebarIndex != sender.tag)
        {
            // 检查是否存在详情视图
            UIViewController *detailController = [self findDetailViewController:self.view];
            if (detailController != nil)
            {
                if ([detailController respondsToSelector:@selector(dismissView)])
                {
                    // 关闭外卖、订座详情
                    [detailController performSelector:@selector(dismissView)];
                }
                else if ([detailController respondsToSelector:@selector(tryDismissView)])
                {
                    // 关闭点菜、购物车页面
                    [detailController performSelector:@selector(tryDismissView)];
                }
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                // 停止接受事件
                [appDelegate.window setUserInteractionEnabled:NO];
                
                while ([detailController.view superview] != nil)
                {
                    // 用户取消跳转
                    if (self.breakPressAction)
                    {
                        self.breakPressAction = NO;
                        
                        // 继续接受事件
                        [appDelegate.window setUserInteractionEnabled:YES];
                        
                        return;
                    }
                    // 代码暂停，等待关闭之后再继续
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                             beforeDate:[NSDate distantFuture]];
                }
                
                // 继续接受事件
                [appDelegate.window setUserInteractionEnabled:YES];
            }
            
            // 移除之前的页面
            switch (selectedSidebarIndex)
            {
                case kDiningTableSideBarTag:
                {
                    [dtMainViewCtrl dismissDiningTableMainView];
                    [dtMainViewCtrl removeFromParentViewController];
                    break;
                }
                case kTakeOutSideBarTag:
                {
                    [takeoutMainCtrl dismissView];
                    [takeoutMainCtrl removeFromParentViewController];
                    break;
                }
                case kPreOrderSideBarTag:
                {
                    [preorderMainCtrl dismissView];
                    [preorderMainCtrl removeFromParentViewController];
                    break;
                }
                case kDishCardSideBarTag:
                {
                    [dishCardCtrl dismissView];
                    [dishCardCtrl removeFromParentViewController];
                    break;
                }
                case kQueueSideBarTag:
                {
                    [queueMainCtrl dismissView];
                    [queueMainCtrl removeFromParentViewController];
                    break;
                }
                case kCallServiceSideBarTag:
                {
                    [callServiceViewCtrl dismissView];
                    [callServiceViewCtrl removeFromParentViewController];
                    break;
                }
                case kMemberSideBarTag:
                {
                    [memberVC dismissViewControllerWithAnimated:NO];
                    break;
                }
                case kMoreSideBarTag:
                {
                    [moreViewController dismissView];
                    [moreViewController removeFromParentViewController];
//                    sleep(2);
//                    [MoreViewController dellocMoreVCShareInstance];
//                    moreViewController = nil;
                    
                    break;
                }
            }
            
            switch (sender.tag)
            {
                case kDiningTableSideBarTag:
                {
                    // 房台信息
                    if (dtMainViewCtrl == nil || sender.isReload == YES)
                    {
                        dtMainViewCtrl = [[DiningTableMainViewController alloc] init];
                    }
                    [self addChildViewController:dtMainViewCtrl];
                    [dtMainViewCtrl showDiningTableMainViewInView:self.view];
                    
                    break;
                }
                case kTakeOutSideBarTag:
                {
                    // 外卖
                    if (takeoutMainCtrl == nil || sender.isReload == YES)
                    {
                        takeoutMainCtrl = [[TakeoutOrdersMainViewController alloc] init];
                    }
                    [self addChildViewController:takeoutMainCtrl];
                    [takeoutMainCtrl showInView:self.view];
                    
                    
                    break;
                }
                case kPreOrderSideBarTag:
                {
                    // 订座
                    if (preorderMainCtrl == nil || sender.isReload == YES)
                    {
                        preorderMainCtrl = [[PreorderOrderMainViewController alloc] init];
                    }
                    [self addChildViewController:preorderMainCtrl];
                    [preorderMainCtrl showInView:self.view];
                    
                    break;
                }
                case kDishCardSideBarTag:
                {
                    // 菜牌
                    if (dishCardCtrl == nil || sender.isReload == YES)
                    {
                        dishCardCtrl = [[DishCardMainViewController alloc] initWithNibName:@"DishCardMainViewController" bundle:nil];
                    }
                    [self addChildViewController:dishCardCtrl];
                    [dishCardCtrl showInView:self.view];
                    
                    break;
                }
                case kQueueSideBarTag:
                {
                    // 排队
                    if (queueMainCtrl == nil || sender.isReload == YES)
                    {
                        queueMainCtrl = [[QueueMainViewController alloc] init];
                    }
                    [self addChildViewController:queueMainCtrl];
                    [queueMainCtrl showInView:self.view];
                    
                    break;
                }
                case kCallServiceSideBarTag:
                {
                    // 呼叫服务
                    if (callServiceViewCtrl == nil || sender.isReload == YES)
                    {
                        callServiceViewCtrl = [[CallServiceViewController alloc]init];
                    }
                    [self addChildViewController:callServiceViewCtrl];
                    [callServiceViewCtrl showInView:self.view];
                    
                    break;
                }
                case kMemberSideBarTag:
                {
                    // 会员
                    if (memberVC == nil || sender.isReload == YES)
                    {
                        memberVC = [[MemberMainViewController alloc]init];
                    }
                    [memberVC showInView:self withOriginPoint:kViewControllerOrigin withAnimated:YES];
                    
                    break;
                }
                case kMoreSideBarTag:
                {
                    // 更多
                    if (moreViewController == nil || sender.isReload == YES)
                    {
                        moreViewController = [[MoreViewController alloc] init];
                    }
                    [self addChildViewController:moreViewController];
                    [moreViewController showInView:self.view];
                    
                    break;
                }
            }
            selectedSidebarIndex = sender.tag;
            
            if (sender.isReload == YES)
            {
                sender.isReload = NO;
            }
            
            for (int i = 0; i < [leftSideBtnArray count]; i++)
            {
                CustomSideBar *tempSideBar = [leftSideBtnArray objectAtIndex:i];
                if (selectedSidebarIndex == tempSideBar.tag)
                {
                    tempSideBar.bgFlag = YES;
                }
                else
                {
                    tempSideBar.bgFlag = NO;
                }
                [tempSideBar updateViewAfterCreateBar];
            }
            
        }
    }
}

- (UIViewController *)findDetailViewController:(UIView *)view
{
    UIViewController *detailController = nil;
    NSArray *subViews = view.subviews;
    for (UIView *subView in subViews) {
        UIViewController *nextResponder = (UIViewController *)[subView nextResponder];
        if ([nextResponder isKindOfClass:[OrderMessageDetailViewController class]] ||
            [nextResponder isKindOfClass:[DtMenuCookbookViewController class]] ||
            [nextResponder isKindOfClass:[DtMenuCookbookPackageViewController class]] ||
            [nextResponder isKindOfClass:[DtMenuShoppingCarViewController class]] ||
            [nextResponder isKindOfClass:[TakeoutByPhoneViewController class]]) {
            
            detailController = nextResponder;
        } else {
            detailController = [self findDetailViewController:subView];
        }
        
        if (detailController != nil) {
            break;
        }
    }
    
    return detailController;
}


#pragma mark AssistiveTouchDelegate
- (void)assistiveTocuhs
{
    _assistiveTouchView.hidden = YES;
    [self showGrid];
}

- (void)showGrid
{
    if (!self.shortcutItemArr)
    {
        self.shortcutItemArr = [[NSMutableArray alloc]init];
    }
    else
    {
        [self.shortcutItemArr removeAllObjects];
    }
    
    for (ShortcutDataModel *shortcut in self.shortcutArr)
    {
        if (shortcut.isSelected)
        {
            [self.shortcutItemArr addObject:[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:shortcut.shortcutImg] title:shortcut.shortcutName]];
        }
        else
        {
            //[self.shortcutItemArr addObject:[RNGridMenuItem emptyItem]];
            [self.shortcutItemArr addObject:[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"Add"] title:@""]];
        }
    }
    while (self.shortcutItemArr.count < 9)
    {
        [self.shortcutItemArr addObject:[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"Add"] title:@""]];
    }
    
    NSInteger numberOfOptions = self.shortcutItemArr.count;
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[self.shortcutItemArr subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    [av showInViewController:self
                      center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
    
}
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
{
    if (self.shortcutArr.count <= itemIndex)
    {
        AddShortcutMenuViewController *addShortCutCtl = [[AddShortcutMenuViewController alloc]initWithNibName:@"AddShortcutMenuViewController" bundle:nil];
        addShortCutCtl.delegate = self;
        [[MainViewController getMianViewShareInstance] presentPopupViewController:addShortCutCtl animationType:MJPopupViewAnimationSlideBottomBottom];
        // 缩放视图
        scaleView(addShortCutCtl.view);
    }
    else
    {
        ShortcutDataModel *shortcut = (ShortcutDataModel *)[self.shortcutArr objectAtIndex:itemIndex];
        
        if (!shortcut.isSelected)
        {
            AddShortcutMenuViewController *addShortCutCtl = [[AddShortcutMenuViewController alloc]initWithNibName:@"AddShortcutMenuViewController" bundle:nil];
            addShortCutCtl.delegate = self;
            [[MainViewController getMianViewShareInstance] presentPopupViewController:addShortCutCtl animationType:MJPopupViewAnimationSlideBottomBottom];
            // 缩放视图
            scaleView(addShortCutCtl.view);
        }
        else
        {
            if ([shortcut.shortcutTag isEqualToString:@"tag_soldout"])//沽清
            {
                QuickSoldOutSettingViewController *quickSoldOutCtl = [[QuickSoldOutSettingViewController alloc]initWithNibName:@"QuickSoldOutSettingViewController" bundle:nil];
                quickSoldOutCtl.delegate = self;
                quickSoldOutCtl.hotkeyKey = shortcut.shortcutID;
                
                [[MainViewController getMianViewShareInstance] presentPopupViewController:quickSoldOutCtl animationType:MJPopupViewAnimationSlideBottomBottom];
                // 缩放视图
                scaleView(quickSoldOutCtl.view);
            }
            else
            {
                AddShortcutMenuViewController *addShortCutCtl = [[AddShortcutMenuViewController alloc]initWithNibName:@"AddShortcutMenuViewController" bundle:nil];
                addShortCutCtl.delegate = self;
                [[MainViewController getMianViewShareInstance] presentPopupViewController:addShortCutCtl animationType:MJPopupViewAnimationSlideBottomBottom];
                // 缩放视图
                scaleView(addShortCutCtl.view);
            }
            
//            switch ([shortcut.shortcutID intValue])
//            {
//                    _assistiveTouchView.hidden = YES;
//                case 0:
//                {
//
//                }
//                    break;
//                case 4:
//                {
//
//                    
//                }
//                    break;
//                default:
//                    _assistiveTouchView.hidden = NO;
//                    break;
//            }
        }
    }

    
    //    if (kZeroNumber == itemIndex)
    //    {
    //        assistiveTouchView.hidden = NO;
    //        QuickSoldOutSettingViewController *quickSoldOutCtl = [[QuickSoldOutSettingViewController alloc]initWithNibName:@"QuickSoldOutSettingViewController" bundle:nil];
    //        quickSoldOutCtl.delegate = self;
    //
    //        [[MainViewController getMianViewShareInstance] presentPopupViewController:quickSoldOutCtl animationType:MJPopupViewAnimationSlideBottomBottom];
    //    }
    
    
    
}
- (void)gridMenuWillDismiss:(RNGridMenu *)gridMenu
{
    _assistiveTouchView.hidden = NO;
}

#pragma mark EditDiscountViewControllerDelegate
- (void)dismissEditDiscountViewController:(QuickSoldOutSettingViewController *)ctl
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

//- (void)didFinishEditWithNewDiscountModel:(DiscountDataModel *)discountDataModel andIsExistingDiscount:(BOOL)flag
//{
//    if (flag)
//    {
//        [discountDataArr_ replaceObjectAtIndex:discontIndex_ withObject:discountDataModel];
//    }
//    else
//    {
//        [discountDataArr_ addObject:discountDataModel];
//    }
//    [self.discountListTableView reloadData];
//}

#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    if (picker.tag == 0)//获取所有可用快捷键.
    {
        switch (responseStatus)
        {
            case 200:
            {
                NSArray *hotkeyArr = [[dict objectForKey:@"data"]objectForKey:@"list"];
                [self creatShortCutDataModel:hotkeyArr];
                _assistiveTouchView.hidden = NO;
                break;
            }
            default:
            {
                NSString *str = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:str];
                break;
            }
        }
    }
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    
}

// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{

}

@end
