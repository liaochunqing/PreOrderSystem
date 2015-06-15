//
//  LoginViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplyAccountViewController.h"
#import "OfflineManager.h"
#import "MBProgressHUD.h"
#import "JsonPicker.h"

@class MainViewController;

@interface LoginViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate, JsonPickerDelegate, MBProgressHUDDelegate>
{
    __weak UITextField *accountTextfield;
    __weak UITextField *passwordTextfield;
    __weak UIScrollView *loginScrollview;
    __weak UIImageView *backGroundImageView;
    __weak UIButton *clearButton;
    __weak UIImageView *contextImageView;
    __weak UIImageView *logoImageView;
    __weak UIImageView *accountImageView;
    __weak UIImageView *passwordImageView;
    __weak UIImageView *accountLineImageView;
    __weak UIImageView *passwordLineImageView;
    __weak UIButton *applyBtn;
    
    JsonPicker *jsonPicker;
    OfflineManager *offlineMgr;
    MBProgressHUD *HUD;
    NSMutableArray *downloadingPicsArray;//用于标记"下载图片"的列表
    int totalDownloaded;
}

@property (nonatomic, weak) IBOutlet UITextField *accountTextfield;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextfield;
@property (nonatomic, weak) IBOutlet UIScrollView *loginScrollview;
@property (nonatomic, weak) IBOutlet UIImageView *backGroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *contextImageView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *accountImageView;
@property (nonatomic, weak) IBOutlet UIImageView *passwordImageView;
@property (nonatomic, weak) IBOutlet UIImageView *accountLineImageView;
@property (nonatomic, weak) IBOutlet UIImageView *passwordLineImageView;
@property (nonatomic, weak) IBOutlet UIButton *applyBtn;
@property (nonatomic, weak) IBOutlet UIButton *clearButton;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

- (IBAction)clearBtnClick:(id)sender;
- (void)clearImageData;

@end
