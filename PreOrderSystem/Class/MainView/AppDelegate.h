//
//  AppDelegate.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"

@class JsonPicker;
@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate> {
    
    BOOL shouldRefreshPreorderView;//标记是否需要通知刷新"订座"页面
    BOOL shouldRefreshTakeoutView;//标记是否需要通知刷新"外卖"页面
    BOOL shouldRefreshCallServiceView;//标记是否需要通知刷新"外卖"页面
    BOOL shouldRefreshDinnerTableView;//标记是否需要通知刷新"房台"页面
    NSUncaughtExceptionHandler *uncaughtHandler;
    JsonPicker *_jsonPicker;
    /// 版本信息窗口
    UIWindow *areaWindow_;
    /// 版本信息视图
    UILabel *areaLabel_;
    
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *viewController;




+ (AppDelegate *)appDelegate;

@end
