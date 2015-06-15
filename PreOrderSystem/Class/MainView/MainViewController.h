//
//  MainViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSideBar.h"

#import "AssistiveTouch.h"
#import "RNGridMenu.h"
#import "ShortcutDataModel.h"
#import "QuickSoldOutSettingViewController.h"
#import "AddShortcutMenuViewController.h"

#define kViewControllerOrigin CGPointMake(170, 0)

@interface MainViewController : UIViewController<CustomSideBarDelegate,AssistiveTouchDelegate,RNGridMenuDelegate,QuickSoldOutSettingViewControllerProtocol,JsonPickerDelegate>

/// 中断点击事件（当点击sliderBar某一项之后，用户取消关闭购物车、点菜页面、外卖详情或订座详情时将取消点击事件）。
@property (nonatomic) BOOL breakPressAction;

@property (nonatomic, weak) IBOutlet UIImageView *sideBarBgImageView;
@property (nonatomic, weak) IBOutlet UILabel *navTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgrondImageView;
@property (nonatomic, strong)UIButton *shortcutBtn;//可拖动悬浮快捷按钮

+ (MainViewController *)getMianViewShareInstance;

//**********************快捷按钮测试*********************

//快捷方式界面
@property (nonatomic,strong) AssistiveTouch *assistiveTouchView;

//快捷方式数据模型
@property (nonatomic,strong) NSMutableArray *shortcutArr;

//快捷方式的item集合
@property (nonatomic,strong) NSMutableArray *shortcutItemArr;

//显示快捷界面
- (void)showGrid;

//**********************快捷按钮测试*********************
@end
