//
//  RuleSettingViewController.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"
#import "OrderNoticeCell.h"

@class CustomTimePicker;
@class RulePreorderSettingViewController;
@protocol RulePreorderSettingViewControllerDelegate <NSObject>
-(void)RulePreorderSettingViewController:(RulePreorderSettingViewController*)ctrl didDismissView:(BOOL)flag;
-(void)RulePreorderSettingViewController:(RulePreorderSettingViewController*)ctrl didEditedSuccess:(BOOL)flag;

@end

@interface RulePreorderSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, OrderNoticeCellDelegate>
{
    __weak id <RulePreorderSettingViewControllerDelegate> delegate;
    __weak UITableView *ruleSettingTableview;
    __weak UIButton *quitButton;
    __weak UIButton *trueButton;
    __weak UIImageView *tableBgImageView;
    
    UIButton *preorderOpenRangeButton;//"订座开放期限"按钮
    BOOL isEdited;//用于判断是否己修改过
    NSMutableDictionary *ruleSettingDict;
    NSMutableArray *limitTitlesArray;//开放期限
    
    UIPickerView *selectedPickerview;
    UIDatePicker *selectedDatePicker;
    CustomTimePicker *selectdTimePicker;//选择了那个时间选择器
    id popoverController;
    JsonPicker *jsonPicker;
    
    //标记textField
    NSMutableArray *textFieldArray;
    //标记weekbutton
    NSMutableArray *WeekdayBtnArray;
    NSMutableArray *DesktextFieldArray;
    //订座开发指定时间
    NSMutableArray *specailOpenDesktextFieldArray;
    
    BOOL isOpenRangeButtonClicked;
    UITableViewCell *selectCell;
    CGPoint tableViewContentOffset;
    BOOL _isTextFieldClearButtonClick;
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

//Public Methods
-(void)showInView:(UIView*)aView;
-(void)dismissView;

@end
