//
//  Constants.h
//  Reservation
//
//  Created by  on 11-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#ifndef Reservation_Constants_h

//#define RELEASE 100
//#define DEMO 200
//#define DEMO 200
//#define TEST 300
#define TEST 300


#if TEST
#define kDomainURL @"http://test.etable.api.spydoggy.com/2.6/"
#define kDomainCommonURL @"http://test.m.spydoggy.com/01/"
#elif DEMO
#define kDomainURL @"http://demo.etable.api.spydoggy.com/2.6/"
#define kDomainCommonURL @"http://demo.m.spydoggy.com/01/"
#elif RELEASE
#define kDomainURL @"http://etable.api.spydoggy.com/2.4/"
#define kDomainCommonURL @"http://m.spydoggy.com/01/"
#endif

#define kLangVersion @"1.0.0"

#define kPushToken @"pushToken"
#define kOauthToken @"oAuthToken"
#define kAccountUserName @"accountUserName"
#define kAccountUserPassword @"accountUserPassword"
#define kRestaurantName @"restaurantName"

// 检测是否为iPhone
#define kIsiPhone ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)

// 屏幕适应缩放（缩放iPhone设备中的视图）
#define scaleView(__VIEW__) {while(kIsiPhone) {\
                            CGSize targetSize = CGSizeMake(1024.0, 768.0);\
                            AppDelegate *appDelegate = [AppDelegate appDelegate];\
                            CGSize screenSize = appDelegate.window.bounds.size;\
                            if (screenSize.width < screenSize.height) {\
                                screenSize.width = screenSize.width + screenSize.height;\
                                screenSize.height = screenSize.width - screenSize.height;\
                                screenSize.width = screenSize.width - screenSize.height;\
                            }\
                            __VIEW__.transform = CGAffineTransformMakeScale(screenSize.width / targetSize.width,\
                                                                            screenSize.height / targetSize.height);\
                            break;\
                            }}


#define kSystemAppVersion @"systemAppVersion"
#define kSystemVersionOfCurrentDevice [[[UIDevice currentDevice] systemVersion] floatValue]
#define kSystemVersionIsIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define kSystemVersionLaterIOS5 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)

//注册成功
#define kRegisterAccountSuccess @"registerAccountSuccess"

//左上角的标题，如：
#define kShouldUpdateNavTitle @"shouldUpdateNavTitle"
#define kDiningTableAndDishesLastUpdatedDate @"diningTableAndDishesLastUpdatedDate"
#define kDiningTableList @"diningTableList"
#define kDishesList @"dishesList"
#define kMemosList @"memosList"
#define kAccountInfo @"accountInfo"
#define kBusinessHours @"businessHours"


//规则设置的开放期限列表（即：当天、3天、一个星期、两个星期....）
#define kRuleLimitTitleList @"ruleLimitTitleList"
//保存权限
#define kAccountAuthority @"accountAuthority"
//保存外卖开发权限
#define kTakeoutFunction @"takeoutFunction"
//通知应该更新订座订单列表
#define kUpdatePreOrderListWhenPush @"updatePreOrderListWhenPush"
/*如果推送的订单和正在查看的订单是同一个订单,则要刷新正在查看的订单*/
#define kUpdatePreOrderDetailViewWhenPush @"updatePreOrderDetailViewWhenPush"
//通知应该更新订座订单列表,本地下单
#define kShouldUpdatePreorderOrderListWithLocalOrder @"shouldUpdatePreorderOrderListWithLocalOrder"
//通知己更新订座订单列表 （通过userInfo返回）
#define kDidUpdatedPreorderOrderList @"didUpdatedPreorderOrderList"
//从后台进入前台，通知己更新订座订单列表 
#define kUpdatedPreorderOrderListWhenEnterForeground @"UpdatedPreorderOrderListWhenEnterForeground"
//更新订座的badge
#define kShouldUpdatePreorderOrderNotifNum @"shouldUpdatePreorderOrderNotifNum"
//通知更新sideButton的title
#define kUpdateForLangChangedNotify @"kUpdateForLangChangedNotify"

//通知应该更新外卖订单列表
#define kUpdateTakeoutOrderListWhenPush @"updateTakeoutOrderListWhenPush"
/*如果推送的订单和正在查看的订单是同一个订单,则要刷新正在查看的订单*/
#define kUpdateTakeoutDetailViewWhenPush @"updateTakeoutDetailViewWhenPush"
//通知应该更新外卖订单列表,本地下单
#define kShouldUpdateTakeoutOrderListWithLocalOrder @"shouldUpdateTakeoutOrderListWithLocalOrder"
//通知己更新外卖订单列表 （通过userInfo返回）
#define kDidUpdatedTakeoutOrderList @"didUpdatedTakeoutOrderList"
//从后台进入前台，通知更新外卖订单列表,
#define kUpdatedTakeoutOrderListWhenEnterForeground @"UpdatedTakeoutOrderListWhenEnterForeground"
//更新外卖的badge
#define kShouldUpdateTakeoutOrderNotifNum @"shouldUpdateTakeoutOrderNotifNum"
// 更新外卖催单的badge
#define kShouldUpdateTakeoutRemindersNotifNum @"shouldUpdateTakeoutRemindersNotifNum"

//更新互动的badge
#define kShouldUpdateCallServiceNotifNum @"shouldUpdateCallServiceNotifNum"
#define kShouldUpdateCallServiceList @"shouldUpdateCallServiceList"
#define kUpdatedCallServiceListWhenEnterForeground @"updatedCallServiceList"
#define kUpdatedDinnerTableListWhenEnterForeground @"updatedDinnerTableList"

// 房台
#define kShouldUpdateQueueList @"shouldUpdateQueueList"
// 更新房台数据
#define kShouldUpdateDinningTableList @"shouldUpdateDinningTableList"
// 更新房台的badge
#define kUpdateDinnerTableBadge @"shouldUpdateDinnerTableNotifNum"

//
#define kMenuCellDidPressed @"menuCellDidPressed"

//普通菜项
//点击某“菜单”时响应（新增菜项）
#define kMenuControllerDidAddedDish @"menuControllerDidAddedDish"
//点击某“菜单”时响应（编辑、修改菜项）
#define kMenuControllerDidUpdatedDish @"menuControllerDidUpdatedDish"

//套餐
//点击某“菜单”时响应（新增菜项）
#define kMenuPackageDidAddedDish @"menuPackageDidAddedDish"
//点击某“菜单”时响应（编辑、修改菜项）
#define kMenuPackageDidUpdatedDish @"menuPackageDidUpdatedDish"
//登出
#define kLogoutAccount @"logoutAccount"
//我的帐号下的所有应用
/*#define DOWN_APP_URL  @"itms-apps://itunes.apple.com/cn/artist/idealabc/id475306072"*/
#define DOWN_APP_URL  @"itms-apps:itunes.apple.com/app/id456818090?mt=8"
//每过24小时检测更新
#define kOnedayTranferToSecond   (24*60*60)

//空间小于200M时，每过24小时提醒清空缓存
#define kOnedayclearData @"warnClearDataPerDayWhenSpaceIsLow"

#define kResetDiningTableInfo @"resetDiningTableInfo"

//外卖设置可以上传的图片数
#define kTakeOutPicNum @"takeOutPicNum"
#define kTakeOutSelectedPicNum @"takeOutSelectedPicNum"

// 电话外卖的点菜清单
#define kTakeoutByPhoneDishesListKey @"takeoutByPhoneDishesListKey"
// 电话外卖的用户资料信息
#define kTakeoutByPhoneUserInfoKey @"takeoutByPhoneUserInfoKey"

#define kAccountConnectedPrinterName @"accountConnectedPrinterName"
#define kAccountConnectedPrinterIP @"accountConnectedPrinterIP"
#define kPrintPortSettings @"10000"

//本机当前语言
#define kCurrentLanguageOfDevice [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0]
//简体
#define kChineseFamiliarStyle @"zh-Hans"
//繁体
#define kChineseTraditional @"zh-Hant"

//购物车菜品减少时通知
#define kDishNumChangedFromRightTable @"dishNumChangedFromRightTable"

typedef enum
{
    kTableViewFirstRow = 0,
    kTableViewSecondRow,
    kTableViewThirdRow,
    kTableViewFourthRow,
    kTableViewFifthRow,
    kTableViewSixthRow
}kTableViewRow;

typedef enum
{
    kTableViewFirstSection = 0,
    kTableViewSecondSection,
    kTableViewThirdSection,
    kTableViewFourthSection,
    kTableViewFifthSection,
    kTableViewSixthSection
}kTableViewSection;

typedef enum
{
    kPrinterModeTakeout = 0,
    kPrinterModeQueue,
    kPrinterModeOrderdish,
    kPrinterModeKitch
}kPrinterMode;

/*只有一个Section*/
#define kTableViewOnlyOneSection 0
#define kZeroNumber 0
#define kDelectDishFromCarNotification @"DelectDishFromCarNotification"
#define LoadImageWithPNGType(file) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:@"png"]]

#define kDateFirstFormat @"yyyy-MM-dd"

#endif
