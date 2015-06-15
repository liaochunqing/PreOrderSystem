//
//  RuleTakeoutSettingViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-8-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"
#import "XANImageViewController.h"
#import "TakeOutNoticeCell.h"

@class CustomTimePicker;
@class RuleTakeoutSettingViewController;

@protocol RuleTakeoutSettingViewControllerDelegate <NSObject>

-(void)RuleTakeoutSettingViewController:(RuleTakeoutSettingViewController*)ctrl didDismissView:(BOOL)flag;
-(void)RuleTakeoutSettingViewController:(RuleTakeoutSettingViewController*)ctrl didEditedSuccess:(BOOL)flag;
@end

@interface RuleTakeoutSettingViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, XANImageViewControllerDataSource, TakeOutNoticeCellDelegate>
{
    __weak id <RuleTakeoutSettingViewControllerDelegate> delegate;
    __weak UITableView *ruleSettingTableview;
    __weak UIButton *quitButton;
    __weak UIButton *trueButton;
    __weak UIImageView *tableBgImageView;
    
    CGPoint tableViewContentOffset;
    
    NSMutableDictionary *ruleSettingDict;
    id popoverController;
    JsonPicker *jsonPicker;
    BOOL isEdited;
    
    XANImageViewController *xan;
    
    CustomTimePicker *selectdTimePicker;//选择了那个时间选择器
    NSMutableArray *photoPathArray;//存储图片存储路径
    NSMutableArray *photoViewArray;//存储图片数据
    NSMutableArray *smallPhotoViewArray;//存储图片缩略图数据
    BOOL isModifyPic;
    UITableViewCell *selectCell;
//    NSMutableArray *_feeArray;
    NSMutableArray *_weekdayBtnArray;
    BOOL _isTextFieldClearButtonClick;
    
    UIButton *_privilegeDeadlineAllTimeButton;
    UIButton *_privilegeDeadlinelimitTimeButton;
    
    UITextField *_upperCostTextField;
    UITextField *_upperCarryfeeTextField;
    UITextField *_lowerCostTextField;
    UITextField *_lowerCarryfeeTextField;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UITableView *ruleSettingTableview;
@property (nonatomic, weak) IBOutlet UILabel *openLabel;
@property (nonatomic, weak) IBOutlet UIButton *quitButton;
@property (nonatomic, weak) IBOutlet UIButton *trueButton;
@property (nonatomic, weak) IBOutlet UISwitch *ruleSwitch;
@property (nonatomic, weak) IBOutlet UIImageView *tableBgImageView;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, assign) BOOL isShowing;
//@property (nonatomic, assign) NSInteger addFeeCount;//新增的配餐费天目数
@property (nonatomic, assign) int deliveryType;/*外卖送餐方式 0送餐上门, 1自取*/
@property (nonatomic, strong) NSDictionary *settingBtnDict;//暂停外卖时的数据
@property (nonatomic, strong) NSString *lowerCost;
@property (nonatomic, assign) int clickImgIndex;//点击哪张图片放大

//Public Methods
-(void)showInView:(UIView*)aView;
-(void)dismissView;

@end
