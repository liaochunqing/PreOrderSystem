//
//  ApplyAccountViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//  申请企业帐号
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "MBProgressHUD.h"
#import "WEPopoverController.h"

@class OfflineManager;

@interface ApplyAccountViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate, JsonPickerDelegate, UIAlertViewDelegate>
{
    //餐厅名称（必填）
    __weak IBOutlet UITextField *restNameTextfield;
    //餐厅电话（必填）
    __weak IBOutlet UITextField *restPhoneNumTextfield;
    __weak IBOutlet UITextField *restPhoneNumTextfield2;
    //餐厅联系人（必填）
    __weak IBOutlet UITextField *restContactTextfield;
    //餐厅地址
    __weak IBOutlet UITextField *restAddressTextfield;
    __weak IBOutlet UITextField *restEmailTextfield;
    __weak IBOutlet UIScrollView *restScrollview;
    
    __weak IBOutlet UIImageView *applyBgImageView;
    __weak IBOutlet UIImageView *contextBgImageView;
    __weak IBOutlet UIImageView *logoImageView;
    __weak IBOutlet UIImageView *nameImageView;
    __weak IBOutlet UIImageView *phoneNumImageView;
    __weak IBOutlet UIImageView *contactImageView;
    __weak IBOutlet UIImageView *addressImageView;
    __weak IBOutlet UIButton *submitButton;
    __weak IBOutlet UIButton *cancelButton;
    __weak IBOutlet UIButton *infoButton;
    __weak IBOutlet UIImageView *nameLineImageView;
    __weak IBOutlet UIImageView *phoneNumLineImageView;
    __weak IBOutlet UIImageView *contactLineImageView;
    __weak IBOutlet UIImageView *addressLineImageView;
    __weak IBOutlet UIImageView *emailImageView;
    __weak IBOutlet UIImageView *emailLineImageView;
    
    //开通功能
    __weak IBOutlet UIImageView *openFunctionImageView;
    __weak IBOutlet UIImageView *bookingImageView;
    __weak IBOutlet UIImageView *takeawayImageView;
    __weak IBOutlet UIImageView *menuImageView;
    __weak IBOutlet UIImageView *queueImageView;
    __weak IBOutlet UIImageView *callServiceImageView;
    __weak IBOutlet UILabel *bookingLabel;
    __weak IBOutlet UILabel *takeawayLabel;
    __weak IBOutlet UILabel *menuLabel;
    __weak IBOutlet UILabel *queueLabel;
    __weak IBOutlet UILabel *callServiceLabel;
    
    WEPopoverController *popoverController;
}

@property (nonatomic, weak) UITextField *restNameTextfield;
@property (nonatomic, weak) UITextField *restPhoneNumTextfield;
@property (nonatomic, weak) UITextField *restPhoneNumTextfield2;
@property (nonatomic, weak) UITextField *restContactTextfield;
@property (nonatomic, weak) UITextField *restAddressTextfield;
@property (nonatomic, weak) UITextField *restEmailTextfield;
@property (nonatomic, weak) UIScrollView *restScrollview;
@property (nonatomic, weak) UIImageView *applyBgImageView;
@property (nonatomic, weak) UIImageView *contextBgImageView;
@property (nonatomic, weak) UIImageView *logoImageView;
@property (nonatomic, weak) UIImageView *nameImageView;
@property (nonatomic, weak) UIImageView *phoneNumImageView;
@property (nonatomic, weak) UIImageView *contactImageView;
@property (nonatomic, weak) UIImageView *addressImageView;
@property (nonatomic, weak) UIButton *submitButton;
@property (nonatomic, weak) UIButton *cancelButton;
@property (nonatomic, weak) UIButton *infoButton;
@property (nonatomic, weak) UIImageView *nameLineImageView;
@property (nonatomic, weak) UIImageView *phoneNumLineImageView;
@property (nonatomic, weak) UIImageView *contactLineImageView;
@property (nonatomic, weak) UIImageView *addressLineImageView;
@property (nonatomic, weak) UIImageView *emailImageView;
@property (nonatomic, weak) UIImageView *emailLineImageView;
@property (nonatomic, weak) IBOutlet UIImageView *diningTableImageView;
@property (nonatomic, weak) UIImageView *bookingImageView;
@property (nonatomic, weak) UIImageView *takeawayImageView;
@property (nonatomic, weak) IBOutlet UIImageView *takeaway2ImageView;
@property (nonatomic, weak) UIImageView *queueImageView;
@property (nonatomic, weak) UIImageView *callServiceImageView;
@property (nonatomic, weak) UIImageView *openFunctionImageView;
@property (nonatomic, weak) UIImageView *menuImageView;
@property (nonatomic, weak) IBOutlet UILabel *diningTableLabel;
@property (nonatomic, weak) UILabel *bookingLabel;
@property (nonatomic, weak) UILabel *takeawayLabel;
@property (nonatomic, weak) IBOutlet UILabel *takeaway2Label;
@property (nonatomic, weak) UILabel *menuLabel;
@property (nonatomic, weak) UILabel *queueLabel;
@property (nonatomic, weak) UILabel *callServiceLabel;
@property (nonatomic, strong) WEPopoverController *popoverController;



@end
