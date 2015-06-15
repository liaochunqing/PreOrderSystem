//
//  TakeoutUserInfoViewController.m
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-19.
//
//

#import "TakeoutUserInfoViewController.h"
#import "NsstringAddOn.h"
#import "CustomTimePicker.h"
#import "PSAlertView.h"
#import "JsonPicker.h"
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "Constants.h"
#import "UITextFieldAddition.h"

@interface TakeoutUserInfoViewController () {
    /// 香港号码（临时存储）
    NSString *hongkongPhoneNumber_;
    /// 大陆号码（临时存储）
    NSString *daluPhoneNumber_;
}

@end

@implementation TakeoutUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kTakeoutByPhoneUserInfoKey];
    id deliveryType = [userInfo objectForKey:@"deliveryType"];
    if (deliveryType)
    {
        self.phoneOrderTypeDefault = [[userInfo objectForKey:@"deliveryType"]boolValue];
    }
    // 背景色
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.clipsToBounds = NO;
    
    // 标题头
    self.titleLabel.text = kLoc(@"data_input");
    self.titleLabel.font = [UIFont boldSystemFontOfSize:37.0];
    
    // 名称
    self.nameLabel.text = kLoc(@"user_of_name");
    self.nameTextField.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"optional")];

    
    if ([[userInfo objectForKey:@"guestName"] length] > 0) {
        self.nameTextField.text = [userInfo objectForKey:@"guestName"];
    }
    
    UIImageView *seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    [seperator setFrame:CGRectMake(0.0,
                                   self.nameTextField.frame.size.height - 1.0,
                                   self.nameTextField.frame.size.width,
                                   1.0)];
    self.nameTextField.delegate = self;
    [self.nameTextField addSubview:seperator];
    
    // 电话号码
    self.phoneNumberLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"phone_number")];
    self.phoneNumberTextField.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];

    seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    [seperator setFrame:CGRectMake(0.0,
                                   self.phoneNumberTextField.frame.size.height - 1.0,
                                   self.phoneNumberTextField.frame.size.width,
                                   1.0)];
    self.phoneNumberTextField.delegate = self;
    self.phoneNumberTextField.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
    [self.phoneNumberTextField addSubview:seperator];
    
    [self.daluButton setTitle:kLoc(@"china_mainland") forState:UIControlStateNormal];
    [self.daluButton setImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"]
                     forState:UIControlStateNormal];
    [self.daluButton setImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"]
                     forState:UIControlStateSelected];
    
    [self.hongkongButton setTitle:kLoc(@"china_hongkong") forState:UIControlStateNormal];
    [self.hongkongButton setImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"]
                         forState:UIControlStateNormal];
    [self.hongkongButton setImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"]
                         forState:UIControlStateSelected];
    
    // 手机号码前缀
    self.phoneNumberPrefixLabel.textColor = [UIColor grayColor];
    
    
    if ([[userInfo objectForKey:@"areaCode"] length] > 0) {
        NSString *areaCode = [userInfo objectForKey:@"areaCode"];
        if ([areaCode isEqualToString:@"86"]) {
            self.phoneNumberTextField.text = [userInfo objectForKey:@"mobile"];
            self.daluButton.selected = YES;
            self.hongkongButton.selected = NO;
            self.phoneNumberPrefixLabel.text = @"+86";
        } else {
            self.phoneNumberTextField.text = [userInfo objectForKey:@"mobile"];
            self.daluButton.selected = NO;
            self.hongkongButton.selected = YES;
            self.phoneNumberPrefixLabel.text = @"+852";
        }
    } else {
        self.phoneNumberTextField.text = [userInfo objectForKey:@"mobile"];
        self.daluButton.selected = YES;
        self.hongkongButton.selected = NO;
        self.phoneNumberPrefixLabel.text = @"+86";
    }
    
    // 外卖方式
    self.takeoutTypeLabel.text = [NSString stringWithFormat:@"%@:", kLoc(@"takeout_type")];
    [self.takeoutButton setTitle:kLoc(@"takeout") forState:UIControlStateNormal];
    [self.takeoutButton setImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"]
                        forState:UIControlStateNormal];
    [self.takeoutButton setImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"]
                        forState:UIControlStateSelected];
    
    [self.takeinButton setTitle:kLoc(@"self_pick") forState:UIControlStateNormal];
    [self.takeinButton setImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"]
                       forState:UIControlStateNormal];
    [self.takeinButton setImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"]
                       forState:UIControlStateSelected];
    
    if (!self.phoneOrderTypeDefault)
    {
        [self takeoutButtonAction:self.takeoutButton];
    }
    else
    {
        [self takeinButtonAction:self.takeinButton];
    }
    
    // 地址
    self.addressLabel.text = kLoc(@"of_address");
    //self.addressTextField.placeholder = kLoc(@"(必填)", nil);
    self.addressTextField.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];

    if ([[userInfo objectForKey:@"address"] length] > 0) {
        self.addressTextField.text = [userInfo objectForKey:@"address"];
    }
    
    seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    self.addressTextField.delegate = self;
    [seperator setFrame:CGRectMake(0.0,
                                   self.addressTextField.frame.size.height - 1.0,
                                   self.addressTextField.frame.size.width,
                                   1.0)];
    [self.addressTextField addSubview:seperator];
    
    // 时间
    self.dateLabel.text = kLoc(@"of_times");
    self.dateTextField.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
    
    if ([[userInfo objectForKey:@"takeoutRoom"] intValue] == 0)
    {
        NSString *str = [userInfo objectForKey:@"dateTime"];
        if (!str.length)
        {
            str = kLoc(@"as_soon_as_possible");
        }
        self.dateTextField.text = str;//[userInfo objectForKey:@"dateTime"];
    }
    else
    {
        self.dateTextField.text = kLoc(@"as_soon_as_possible");
    }
    
    seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    [seperator setFrame:CGRectMake(0.0,
                                   self.dateTextField.frame.size.height - 1.0,
                                   self.dateTextField.frame.size.width,
                                   1.0)];
    self.dateTextField.delegate = self;
    [self.dateTextField addSubview:seperator];
}

// 隐藏键盘
- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark - button actions

- (IBAction)hongkongBtnClick:(id)sender
{
    if (self.hongkongButton.isSelected) {
        return;
    }
    
    self.daluButton.selected = NO;
    self.hongkongButton.selected = YES;
    
    // 记住中国大陆当前输入的号码
    daluPhoneNumber_ = self.phoneNumberTextField.text;
    
    // 手机号码前缀
    self.phoneNumberPrefixLabel.text = @"+852";
    
    if ([hongkongPhoneNumber_ length] > 0) {
        self.phoneNumberTextField.text = hongkongPhoneNumber_;
    } else {
        self.phoneNumberTextField.text = @"";
    }
}

//中国大陆
- (IBAction)btnDaluClick:(UIButton *)sender
{
    if (self.daluButton.isSelected) {
        return;
    }
    
    self.hongkongButton.selected = NO;
    self.daluButton.selected = YES;
    
    // 记住中国香港当前输入的号码
    hongkongPhoneNumber_ = self.phoneNumberTextField.text;
    
    // 手机号码前缀
    self.phoneNumberPrefixLabel.text = @"+86";
    
    if ([daluPhoneNumber_ length] > 0) {
        self.phoneNumberTextField.text = daluPhoneNumber_;
    } else {
        self.phoneNumberTextField.text = @"";
    }
}

- (IBAction)takeoutButtonAction:(id)sender
{
    if (self.takeoutButton.isSelected) {
        return;
    }
    
    self.dateTextField.text = kLoc(@"as_soon_as_possible");
    
    self.takeinButton.selected = NO;
    self.takeoutButton.selected = YES;
    
    self.addressLabel.hidden = NO;
    self.addressTextField.hidden = NO;
    
    self.dateLabel.frame = CGRectMake(216.0, 404.0, 86.0, 21.0);
    self.dateTextField.frame = CGRectMake(318, 400.0, 233.0, 30.0);
}

- (IBAction)takeinButtonAction:(id)sender
{
    if (self.takeinButton.isSelected) {
        return;
    }
    
    self.dateTextField.text = @"";
    
    self.takeoutButton.selected = NO;
    self.takeinButton.selected = YES;
    
    self.addressLabel.hidden = YES;
    self.addressTextField.hidden = YES;
    
    self.dateLabel.frame = self.addressLabel.frame;
    self.dateTextField.frame = self.addressTextField.frame;
}

- (IBAction)btnCancelClick:(UIButton *)sender
{
    [self hideKeyBoard];
    // 关闭
    if ([self.delegate respondsToSelector:@selector(takeoutUserInfoViewControllerDidDismiss:)]) {
        [self.delegate takeoutUserInfoViewControllerDidDismiss:self];
    }
}

// 确定按钮
- (IBAction)sureBtnClick:(UIButton *)sender
{
    [self hideKeyBoard];
    
    if ((self.takeoutButton.isSelected && [self.addressTextField.text length] == 0) ||
        [self.dateTextField.text length] == 0 || [self.phoneNumberTextField.text length] == 0) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_complete_info")];
        return;
    }
    
    if (self.daluButton.isSelected && [self.phoneNumberTextField.text length] != 11) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_phone_number_which_length_is_eleven")];
        return;
    }
    
    if (self.hongkongButton.isSelected && [self.phoneNumberTextField.text length] != 8) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_phone_number_which_length_is_eight")];
        return;
    }
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *dateTime = [format dateFromString:self.dateTextField.text];
    
    if (NSOrderedAscending == [dateTime compare:[NSDate date]]) {
        if (self.takeoutButton.isSelected) {
            [PSAlertView showWithMessage:kLoc(@"takeout_time_pass_error")];
        } else {
            [PSAlertView showWithMessage:kLoc(@"self_pick_time_pass_error")];
        }
        return;
    }
    
    // 保存数据
    [self saveDatas];
}

/**
 * @brief   保存数据。
 *
 */
- (void)saveDatas
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    if ([self.nameTextField.text length] > 0) {
        [userInfo setObject:self.nameTextField.text forKey:@"guestName"];
    }
    
    [userInfo setObject:[self.phoneNumberPrefixLabel.text substringFromIndex:1] forKey:@"areaCode"];
    [userInfo setObject:self.phoneNumberTextField.text forKey:@"mobile"];
    
    if (self.takeoutButton.isSelected) {
        [userInfo setObject:[NSNumber numberWithInt:0] forKey:@"type"];
        [userInfo setObject:self.addressTextField.text forKey:@"address"];
        [userInfo setObject:[NSNumber numberWithInt:0] forKey:@"deliveryType"];
    } else {
        [userInfo setObject:[NSNumber numberWithInt:1] forKey:@"type"];
        [userInfo setObject:[NSNumber numberWithInt:1] forKey:@"deliveryType"];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:self.dateTextField.text];
    
    if (date != nil) {
        [userInfo setObject:self.dateTextField.text forKey:@"dateTime"];
        [userInfo setObject:[NSNumber numberWithInt:0] forKey:@"takeoutRoom"];
    } else {
        [userInfo setObject:[NSNumber numberWithInt:1] forKey:@"takeoutRoom"];
    }
    // 保存到本地
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:userInfo forKey:kTakeoutByPhoneUserInfoKey];
    [userDefault synchronize];
    
    // 关闭
    if ([self.delegate respondsToSelector:@selector(takeoutUserInfoViewControllerDidDismiss:)]) {
        [self.delegate takeoutUserInfoViewControllerDidDismiss:self];
    }
}

#pragma mark - picker

// 日期选择器
- (void)datePickerCreate
{
    NSString *soonTitle = kLoc(@"as_soon_as_possible");
    if (self.takeinButton.isSelected) {
        soonTitle = nil;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", @""]
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:kLoc(@"confirm")
                                  otherButtonTitles:soonTitle, nil];
    actionSheet.tag = 1;
    if (self.datetimePicker == nil)
    {
        self.datetimePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0.0, 270.0, 300.0)];
        if (kIsiPhone)
        {
            self.datetimePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        }
        self.datetimePicker.backgroundColor = [UIColor clearColor];
    }
    
    if ([self.dateTextField.text length] > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [dateFormatter dateFromString:self.dateTextField.text];
        
        if (date == nil)
        {
            date = [NSDate date];
        }
        self.datetimePicker.date = date;
    }
    
    [actionSheet addSubview:self.datetimePicker];
    CGRect textFrame = self.dateTextField.frame;
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:textFrame inView:self.scrollView animated:YES];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    if ([textField isEqual:self.dateTextField]) {
        // 时间选择
        [self hideKeyBoard];
        [self performSelector:@selector(datePickerCreate)
                   withObject:nil
                   afterDelay:0.3];
        return NO;
    }
    
    if ([textField isEqual:self.addressTextField]) {
        [self.basicScrollview setContentOffset:CGPointMake(0, 180) animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.addressTextField]) {
        [self.basicScrollview setContentOffset:CGPointZero animated:YES];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.phoneNumberTextField]) {
        if ([NSString isValidateNumber:string] == NO) {
            // 输入的不是数字
            return NO;
        } else if(newString.length > 11 && self.daluButton.isSelected) {
            // 限制11位数
            return NO;
        } else if(newString.length > 8 && self.hongkongButton.isSelected) {
            // 限制8位数
            return NO;
        }
    }
    
    return YES;
}

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (actionSheet.tag) {
        case 1: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                // 时间选择完成
                self.dateTextField.text = [NSString dateToNSString:self.datetimePicker.date
                                                        withFormat:@"yyyy-MM-dd HH:mm"];
            } else {
                // 尽快送达
                self.dateTextField.text = kLoc(@"as_soon_as_possible");
            }
            break;
        }
            
        default: {
            break;
        }
    }
}

@end
