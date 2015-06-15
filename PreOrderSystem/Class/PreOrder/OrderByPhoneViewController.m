//
//  OrderByPhoneViewController.m
//  PreOrderSystem
//
//  Created by 溢航软件 on 14-4-3.
//
//jhh_订座_电话订座

#import "OrderByPhoneViewController.h"

#import "NsstringAddOn.h"
#import "CustomTimePicker.h"
#import "PSAlertView.h"
#import "JsonPicker.h"
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "Constants.h"
#import "UITextFieldAddition.h"

@interface OrderByPhoneViewController ()<JsonPickerDelegate>
{
    NSString *_hongkongPhoneNumber ;
    NSString *_daluPhoneNumber;
    JsonPicker *_jsonPicker;
}
@end

@implementation OrderByPhoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.force = 0;
    
    // 添加关闭按钮
    [self.phoneNumber bindCloseButton];
    [self.number bindCloseButton];
    
    // 背景色
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.clipsToBounds = NO;
    
    // 标题头
    self.outline.text = kLoc(@"order_seat_by_phone");
    self.outline.font = [UIFont boldSystemFontOfSize:37.0];
    
    // 名称
    self.nameLabel.text = kLoc(@"user _of_name");
    self.name.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"optional")];
    UIImageView *seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    [seperator setFrame:CGRectMake(0, self.name.frame.size.height - 1, self.name.frame.size.width, 1)];
    self.name.delegate = self;
    [self.name addSubview:seperator];
    
    // 电话号码
    self.phonenumberLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"phone_number")];
    self.phoneNumber.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
    seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    [seperator setFrame:CGRectMake(0, self.phoneNumber.frame.size.height - 1, self.phoneNumber.frame.size.width, 1)];
    self.phoneNumber.delegate = self;
    self.phoneNumber.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
    [self.phoneNumber addSubview:seperator];
    
    self.phoneNumber.returnKeyType = UIReturnKeyNext;
    self.daluLabel.text = kLoc(@"china_mainland");
    self.hongkongLabel.text = kLoc(@"china_hongkong");
    
    self.dalu.selected = YES;
    [self.dalu setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"] forState:UIControlStateNormal];
    [self.dalu setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"] forState:UIControlStateSelected];
    
    [self.hongkong setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"] forState:UIControlStateNormal];
    [self.hongkong setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"] forState:UIControlStateSelected];
    
    // 手机号码前缀
    self.phoneNumberPrefix.text = @"+86";
    self.phoneNumberPrefix.textColor = [UIColor grayColor];

    
    // 人数
    self.numberLabel.text = kLoc(@"persons_no");
    self.number.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
    seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    self.number.delegate = self;
    [seperator setFrame:CGRectMake(0, self.number.frame.size.height - 1, self.number.frame.size.width, 1)];
    
    [self.number addSubview:seperator];
    
    // 日期
    self.dateLabel.text = kLoc(@"dates");
    self.date.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
    seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    [seperator setFrame:CGRectMake(0, self.date.frame.size.height - 1, self.date.frame.size.width, 1)];
    self.date.delegate = self;
    [self.date addSubview:seperator];
    
    // 时间
    self.timeLabel.text = kLoc(@"of_time");
    self.time.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
    seperator = [[UIImageView alloc] init];
    seperator.backgroundColor = [UIColor grayColor];
    [seperator setFrame:CGRectMake(0, self.time.frame.size.height - 1, self.time.frame.size.width, 1)];
    self.time.delegate = self;
    [self.time addSubview:seperator];
    
    //获取日期数据
    [self getDateFromServer];
}

// 隐藏键盘
- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}


- (void)dismissOrderByPhoneView:(NSDictionary *)preOrderDict
{
    if ([self.delegate respondsToSelector:@selector(orderByPhoneViewController:withLastestPreOrderData:)])
    {
        [self.delegate orderByPhoneViewController:self withLastestPreOrderData:preOrderDict];
    }
}

#pragma mark -- buttonClick
//中国香港
- (IBAction)hongkongBtnClick:(id)sender
{
    if (self.hongkong.selected == YES)
    {
        return;
    }
    
    self.dalu.selected = NO;
    self.hongkong.selected = YES;
    self.phoneNumber.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];

    
    // 记住中国大陆当前输入的号码
    _daluPhoneNumber = self.phoneNumber.text;
    
    // 手机号码前缀
    self.phoneNumberPrefix.text = @"+852";
    
    if ([_hongkongPhoneNumber length] > 0)
    {
        self.phoneNumber.text = _hongkongPhoneNumber;
    }
    else
    {
        self.phoneNumber.text = @"";
    }
}

//中国大陆
- (IBAction)btnDaluClick:(UIButton *)sender
{
    if (self.dalu.selected == YES)
    {
        return;
    }
    
    self.hongkong.selected = NO;
    self.dalu.selected = YES;
    self.phoneNumber.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
    
    // 记住中国香港当前输入的号码
    _hongkongPhoneNumber = self.phoneNumber.text;
    
    // 手机号码前缀
    self.phoneNumberPrefix.text = @"+86";

    if ([_daluPhoneNumber length] > 0)
    {
        self.phoneNumber.text = _daluPhoneNumber;
    }
    else
    {
        self.phoneNumber.text = @"";
    }
}

//取消按钮
- (IBAction)btnCancelClick:(UIButton *)sender
{
    [self hideKeyBoard];
    [self dismissOrderByPhoneView:nil];
}

//确定按钮
- (IBAction)sureBtnClick:(UIButton *)sender
{
    [self hideKeyBoard];
    
    NSLog(@"self.date.text == %@",self.date.text) ;
    if ([self.number.text length] == 0 || [self.date.text length] == 0 ||
        [self.time.text length] == 0 || [self.phoneNumber.text length] == 0) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_complete_info")];
        return;
    }
    
    if (self.dalu.selected && [self.phoneNumber.text length] != 11) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_phone_number_which_length_is_eleven")];
        return;
    }
    
    if (self.hongkong.selected && [self.phoneNumber.text length] != 8) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_phone_number_which_length_is_eight")];
        return;
    }
    
    if ([self.number.text compare:@"0"] == NSOrderedSame) {
        [PSAlertView showWithMessage:kLoc(@"person_number_cannot_be_0")];
        return;
    }
    
    if ([self.number.text intValue] > 500) {
        [PSAlertView showWithMessage:kLoc(@"person_number_up_to_500")];
        return;
    }
    
    NSString *dateTimeStr = [NSString stringWithFormat:@"%@ %@",self.date.text,self.time.text];
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *dateTime=[format dateFromString:dateTimeStr];
    
    if (NSOrderedAscending == [dateTime compare:[NSDate date]]) {
        [PSAlertView showWithMessage:kLoc(@"preorder_time_cannot_be_past")];
        return;
    }
    
    // 发送到服务器
    [self saveData];
}


#pragma mark -- network
//获取日期
- (void)getDateFromServer
{
    if (nil == _jsonPicker)
    {
        _jsonPicker = [[JsonPicker alloc] init];
    }
    
    _jsonPicker.delegate = self;
    _jsonPicker.tag = 2;
    _jsonPicker.showActivityIndicator = YES;
    _jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    _jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [_jsonPicker postData:postData withBaseRequest:@"booking/dateList"];
}

//获取时间
- (void)getTimeFromServer
{
    if (nil == _jsonPicker)
    {
        _jsonPicker = [[JsonPicker alloc] init];
    }
    
    _jsonPicker.delegate = self;
    _jsonPicker.tag = 3;
    _jsonPicker.showActivityIndicator = YES;
    _jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    _jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [_jsonPicker postData:postData withBaseRequest:@"booking/timeList"];
}

// 网络请求
- (void)saveData
{
    NSString *mobile = nil;
    
    if (self.dalu.selected)
    {
        mobile = [NSString stringWithFormat:@"86%@",self.phoneNumber.text ];
    }
    else if(self.hongkong.selected)
    {
        mobile = [NSString stringWithFormat:@"852%@",self.phoneNumber.text ];
    }
    
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date.text , self.time.text];
    
    if (nil == _jsonPicker)
    {
        _jsonPicker = [[JsonPicker alloc] init];
    }
    
    _jsonPicker.delegate = self;
    _jsonPicker.tag = 1;
    _jsonPicker.showActivityIndicator = YES;
    _jsonPicker.loadingMessage = kLoc(@"saving_data_please_wait");
    _jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    
    if (self.name.text && [self.name.text length] > 0)
    {
        [postData setObject:self.name.text forKey:@"name"];
    }
    
    [postData setObject:mobile forKey:@"mobile"];
    [postData setObject:self.number.text forKey:@"people"];
    [postData setObject:dateTime forKey:@"time"];
    [postData setObject:[NSNumber numberWithInteger:self.force] forKey:@"force"];
    [_jsonPicker postData:postData withBaseRequest:@"booking/orderbyphone"];
}

#pragma mark --picker
// 日期选择器
- (void)datePickerCreate
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", @""]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    actionSheet.tag = 1;
    
    // 日期选择，默认为当前日期，如果当前日期不在候选范围，默认为第一个（根据dateArray）
    NSInteger yearIndex = 0;
    NSInteger monthIndex = 0;
    NSInteger dayIndex = 0;
    NSArray *dates = nil;
    
    if (self.date.text.length > 0)
    {
        dates = [self.date.text componentsSeparatedByString:@"-"];
        // 检测日期是否在候选范围
        BOOL isContains = NO;
        for (NSDictionary *yearDict in self.dateArray)
        {
            // 年份检测
            int year = [[yearDict objectForKey:@"name"] intValue];
            if ([[dates firstObject] intValue] == year)
            {
                // 年份存在，获取月份列表
                NSArray *months = [yearDict objectForKey:@"next"];
                
                for (NSDictionary *monthDict in months)
                {
                    // 月份检测
                    int month = [[monthDict objectForKey:@"name"] intValue];
                    if ([[dates objectAtIndex:1] intValue] == month)
                    {
                        // 月份存在，获取日数列表
                        NSArray *days = [monthDict objectForKey:@"next"];
                        for (NSDictionary *dayDict in days)
                        {
                            // 日数检测
                            int day = [[dayDict objectForKey:@"name"] intValue];
                            if ([[dates lastObject] intValue] == day)
                            {
                                // 日数存在，结束检测
                                isContains = YES;
                                break;
                            }
                            else
                            {
                                dayIndex++;
                            }
                        }
                    }
                    
                    if (isContains)
                    {
                        // 已经找到，不用继续了
                        break;
                    }
                    else
                    {
                        monthIndex++;
                    }
                }
            }
            
            if (isContains)
            {
                // 已经找到，不用继续了
                break;
            }
            else
            {
                yearIndex++;
            }
        }
        
        if (!isContains)
        {
            // 没有找到，不在候选范围，默认选择第一个
            yearIndex = 0;
            monthIndex = 0;
            dayIndex = 0;
        }
        
    }
    else
    {
        // 没有找到，不在候选范围，默认选择第一个
        yearIndex = 0;
        monthIndex = 0;
        dayIndex = 0;
    }

    if (self.datePicker == nil)
    {
        
        if (kIsiPhone) {
            self.datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                             0.0,
                                                                             actionSheet.bounds.size.width,
                                                                             300.0)];
        } else {
            self.datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 270.0, 300.0)];
        }
        self.datePicker.tag = 1;
        self.datePicker.delegate = self;
        self.datePicker.dataSource = self;
        self.datePicker.showsSelectionIndicator = YES;
    }
    
//    [self.datePicker reloadComponent:0];
    [self.datePicker selectRow:yearIndex inComponent:0 animated:NO];
//    [self.datePicker reloadComponent:1];
    [self.datePicker selectRow:monthIndex inComponent:1 animated:NO];
//    [self.datePicker reloadComponent:2];
    [self.datePicker selectRow:dayIndex inComponent:2 animated:NO];
    
    [actionSheet addSubview:self.datePicker];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:self.date.frame inView:self.scrollView animated:YES];
    }
}

// 时间选择器
- (void)timePickerCreate
{
    if (self.timeArray.count == 0)
    {
        return;
    }
    
    if (self.date.text.length == 0)
    {
        [PSAlertView showWithMessage:kLoc(@"please_select_the_date_of_order_seat")];
        return;
    }
    
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    actionSheet.tag = 2;
    if (kIsiPhone) {
        self.timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         actionSheet.bounds.size.width,
                                                                         300.0)];
    } else {
        self.timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 270.0, 300.0)];
    }
    self.timePicker.tag = 2;
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    self.timePicker.showsSelectionIndicator = YES;
    
    // 时间选择，默认选择第一个（根据timearray）
    if (self.time.text.length > 0)
    {
        if ([self.timeArray containsObject:self.time.text])
        {
            [self.timePicker selectRow:[self.timeArray indexOfObject:self.time.text]
                  inComponent:0
                     animated:NO];
        } else
        {
            [self.timePicker selectRow:0 inComponent:0 animated:NO];
        }
    }
    else
    {
        [self.timePicker selectRow:0 inComponent:0 animated:NO];
    }
    
    [actionSheet addSubview:self.timePicker];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:self.time.frame inView:self.scrollView animated:YES];
    }
}

// 限制只能输入0到9的数字
- (BOOL)validateNumber:(NSString*)number
{
    int i = 0;
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (i < number.length)
    {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        
        if (range.length == 0)
        {
            res = NO;
            break;
        }
        
        i++;
    }
    
    return res;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    if (textField == self.date)//日期，弹出日期选择
    {
        [self hideKeyBoard];
        [self datePickerCreate];
        return NO;
    }
    
    if (textField == self.time )//时间，弹出时间选择
    {
        [self hideKeyBoard];
        [self timePickerCreate];
        return NO;
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(range.location >= 11 && textField == self.phoneNumber && self.dalu.selected)
    {// 限制11位数
        return NO;
    }
    else if(range.location >= 8 && textField == self.phoneNumber && self.hongkong.selected)
    {// 限制8位数
        return NO;
    }
    
    // 限制只能输入数字
    if (textField == self.number || textField == self.phoneNumber)
    {
        return [self validateNumber:string];
    }

    
    return YES;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1://日期 ，显示日期
        {
            if (0 == buttonIndex)
            {
                // 日期选择完成
                NSInteger yearIndex = [self.datePicker selectedRowInComponent:0];
                NSInteger monthIndex = [self.datePicker selectedRowInComponent:1];
                NSInteger dayIndex = [self.datePicker selectedRowInComponent:2];
                
                NSDictionary *yearDict = [self.dateArray objectAtIndex:yearIndex];
                int year = [[yearDict objectForKey:@"name"] intValue];
                NSArray *monthList = [yearDict objectForKey:@"next"];
                NSDictionary *monthDict = [monthList objectAtIndex:monthIndex];
                int month = [[monthDict objectForKey:@"name"] intValue];
                NSArray *dayList = [monthDict objectForKey:@"next"];
                int day = [[[dayList objectAtIndex:dayIndex] objectForKey:@"name"] intValue];
                
                NSString *targetDateString = [NSString stringWithFormat:@"%.4d-%.2d-%.2d", year, month, day];
                
                if ([self.date.text isEqualToString:targetDateString] == NO)
                {
                    self.date.text = targetDateString;
                    
                    // 获取时间
                    if (_jsonPicker == nil)
                    {
                        _jsonPicker = [[JsonPicker alloc] init];
                    }
                    _jsonPicker.delegate = self;
                    _jsonPicker.tag = 3;
                    _jsonPicker.showActivityIndicator = YES;
                    _jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
                    _jsonPicker.loadedSuccessfulMessage = nil;
                    _jsonPicker.isShowUpdateAlert = YES;
                    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
                    [postData setObject:self.date.text forKey:@"bookingDate"];
                    [_jsonPicker postData:postData withBaseRequest:@"booking/timeList"];
                }
            }
            break;
        }
            
        case 2://时间，显示时间
        {
            if (0 == buttonIndex)
            {
                // 时间选择完成
                NSInteger timeIndex = [self.timePicker selectedRowInComponent:0];
                NSString *timeString = [self.timeArray objectAtIndex:timeIndex];
                
                self.time.text = timeString;
            }
            break;
        }

        default:
            break;
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0://取消
        {
            if (kIsiPhone) {
                // iPhone版使用渐变动画，否则会出现215度角移动效果
                [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
            } else {
                [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
            }
            break;
        }
            
        case 1://确定
        {
            self.force = 1;
            [self saveData];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.datePicker)
    {
        return 3;
    }
    else if (pickerView == self.timePicker)
    {
        return 1;
    }
    else
    {
        return 1;
    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.datePicker)//日期
    {
        if (component == 0)//年
        {
            return self.dateArray.count;
        }
        else if (component == 1)//月
        {
            NSInteger yearIndex = [pickerView selectedRowInComponent:0];
            NSArray *monthList = [[self.dateArray objectAtIndex:yearIndex] objectForKey:@"next"];
            return monthList.count;
        }
        else if (component == 2)//日
        {
            NSInteger yearIndex = [pickerView selectedRowInComponent:0];
            NSArray *monthList = [[self.dateArray objectAtIndex:yearIndex] objectForKey:@"next"];
            
            NSInteger monthIndex = [pickerView selectedRowInComponent:1];
            NSArray *dayList = [[monthList objectAtIndex:monthIndex] objectForKey:@"next"];
            return dayList.count;
        }

    }
    else if (pickerView == self.timePicker)//时间
    {
        return self.timeArray.count;
    }
    
    return 1;
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)] ;
    
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    if (pickerView == self.datePicker)//日期
    {
        if (component == 0)// 年
        {
            int year = [[[self.dateArray objectAtIndex:row] objectForKey:@"name"] intValue];
            label.text = [NSString stringWithFormat:@"%.4d", year];
        }
        else if (component == 1) //月
        {
            NSInteger yearIndex = [pickerView selectedRowInComponent:0];
            NSArray *monthList = [[self.dateArray objectAtIndex:yearIndex] objectForKey:@"next"];
            int month = [[[monthList objectAtIndex:row] objectForKey:@"name"] intValue];
            label.text =  [NSString stringWithFormat:@"%.2d", month];
        }
        else if (component == 2)//日
        {
            NSInteger yearIndex = [pickerView selectedRowInComponent:0];
            NSArray *monthList = [[self.dateArray objectAtIndex:yearIndex] objectForKey:@"next"];
            
            NSInteger monthIndex = [pickerView selectedRowInComponent:1];
            NSArray *dayList = [[monthList objectAtIndex:monthIndex] objectForKey:@"next"];
            int day = [[[dayList objectAtIndex:row] objectForKey:@"name"] intValue];
            label.text =  [NSString stringWithFormat:@"%.2d", day];
        }
    }
    else if (pickerView == self.timePicker)//时间
    {
        [label setText:self.timeArray[row]];
        
    }
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.datePicker)
    {
        if (component == 0)
        {
            [pickerView reloadComponent:1];
        }
        else if (component == 1)
        {
            [pickerView reloadComponent:2];
        }
    }
}

#pragma mark - JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    NSDictionary *dataDict = [dict objectForKey:@"data"];
    if (picker.tag == 1)//保存数据
    {
        switch (responseStatus)
        {
            case 200:// 成功
            {
                [self performSelector:@selector(dismissOrderByPhoneView:) withObject:dataDict afterDelay:1.0];
                break;
            }
                
            case 202:
            {
                UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"you_have_been_ordered_continue_to_order_seat") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
                [alertview show];
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
    else if (picker.tag == 2)//获取日期
    {
        switch (responseStatus)
        {
            case 200:// 成功
            {
                self.dateArray = [[NSMutableArray alloc] initWithArray:[dataDict objectForKey:@"dateList"]];
                break;
            }
                
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
    else if (picker.tag == 3)//获取时间
    {
        if (self.timeArray)
        {
            [self.timeArray removeAllObjects];
        }
        
        switch (responseStatus)
        {
            case 200:// 成功
            {
                // 清空旧时间
                self.timeArray = [[NSMutableArray alloc] initWithArray:[dataDict objectForKey:@"timeList"]];
                
                // 如果当前没有时间选择，弹出提示
                if (self.timeArray.count == 0)
                {
                    self.time.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"no_order_time")];
                }
                else
                {
//                    self.time.text = @"";
                    self.time.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"optional")];
                }
                break;
            }
                
            default:
            {
//                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                self.time.text = @"";
                self.time.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"no_order_time")];
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
