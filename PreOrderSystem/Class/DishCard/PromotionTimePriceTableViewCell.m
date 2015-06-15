//
//  PromotionTimePriceTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-7-19.
//
//

#import "PromotionTimePriceTableViewCell.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "NsstringAddOn.h"
#import "CustomTimePicker.h"
#import "NumPicker.h"
#import "PSPopoverBckgroundView.h"
#import "Constants.h"
#import "WEPopoverController.h"
#import "MainViewController.h"

@implementation PromotionTimePriceTableViewCell
{
    CustomTimePicker *_timePicker;
    UITextField *_startTimeTextField;
    UITextField *_endTimeTextField;
    UITextField *_priceTextField;
    NSMutableDictionary *_timePriceDict;
    UIButton *_deleteButton;
    UILabel *_timeLabel;
    UILabel *_priceLabel;
    NumPicker *_picker;
    id _popoverController;
    BOOL _isTextFieldClearButtonClick;
}

- (void)awakeFromNib
{
    // Initialization code
    float space = 5;
    float baseX = 5;
    float h = 35;//textField高度
    float w = 100;//textField宽度
    float y = space;//每一行textfield的y坐标
    UIColor *color = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
    
    //时间：
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(baseX, y, 52, 25)];
    _timeLabel.tag = 0;
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor blackColor];
    //_timeLabel.text = kLoc(@"时间：", nil);
    _timeLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"time")];

    [self.contentView addSubview:_timeLabel];
    
    //开始时间
    UITextField *textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_timeLabel.frame) , y , w, h)];
    textfield1.tag = 1;
    textfield1.delegate = self;
    textfield1.borderStyle = UITextBorderStyleNone;
    textfield1.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
    textfield1.textColor = color;
    textfield1.textAlignment = UITextAlignmentCenter;
    textfield1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    textfield1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield1.font = [UIFont systemFontOfSize:18];
    textfield1.placeholder = kLoc(@"start_time");
    textfield1.clearButtonMode = UITextFieldViewModeAlways;
    _startTimeTextField = textfield1;
    [self.contentView addSubview:textfield1];
    
    
    //“至”
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield1.frame) + space, y, 20, 25)];
//    label1.tag = 2;
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor blackColor];
    label1.text = NSLocalizedString(@"~", nil);
    [self.contentView addSubview:label1];
    
    
    //结束时间
    UITextField *textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame) + space, y, w, h)];
    textfield2.tag = 2;
    textfield2.delegate = self;
    textfield2.borderStyle = UITextBorderStyleNone;
    textfield2.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
    textfield2.textColor = color;
    textfield2.textAlignment = UITextAlignmentCenter;
    textfield2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    textfield2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield2.font = [UIFont systemFontOfSize:18];
    textfield2.placeholder = kLoc(@"end_time");
    textfield2.clearButtonMode = UITextFieldViewModeAlways;
    _endTimeTextField = textfield2;
    [self.contentView addSubview:textfield2];
    
    // 优惠：
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield2.frame) + 100, y, 52, 25)];
//    label2.tag = 0;
    _priceLabel.backgroundColor = [UIColor clearColor];
    _priceLabel.textColor = [UIColor blackColor];
    //_priceLabel.text = kLoc(@"优惠：", nil);
    _priceLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"preferential")];

    [self.contentView addSubview:_priceLabel];
    
    //优惠TextField
    UITextField *textfield3 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_priceLabel.frame) , y, w, h)];
    textfield3.tag = 3;
    textfield3.delegate = self;
    textfield3.borderStyle = UITextBorderStyleNone;
    textfield3.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
    textfield3.textColor = color;
    textfield3.textAlignment = UITextAlignmentCenter;
    textfield3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    textfield3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield3.font = [UIFont systemFontOfSize:18];
    textfield3.placeholder = kLoc(@"money");
    _priceTextField = textfield3;
    [self.contentView addSubview:textfield3];
    
    //删除CELL按钮
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.tag = 4;
    [_deleteButton setFrame:CGRectMake(self.frame.size.width - 32, y, 30, 30)];
    [_deleteButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_deleteButton.png"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteElement:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteButton];
    
    //加上一条横线
    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(textfield1.frame) + space - 1, self.contentView.frame.size.width, 1)];
    lineImageView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:lineImageView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateCellInfo:(NSMutableDictionary *)info
{
    if (info == nil) {
        return;
    }
    
    _startTimeTextField.text = [info objectForKey:@"fromTime"];
    _endTimeTextField.text = [info objectForKey:@"toTime"];
    _priceTextField.text = [info objectForKey:@"offer"];
    _timePriceDict = info;
    
    _timeLabel.hidden = YES;
    _priceLabel.hidden = YES;
}

- (void)deleteElement:(UIButton *)btn
{
    if (self.deleteBlock)
    {
        self.deleteBlock();
    }
}

#pragma mark --picker
//数字选择器
- (void)numberPicker:(UITextField *)textField
{
    if (!_picker)
    {
        _picker = [[NumPicker alloc] init];
    }
    _picker.delegate = self;
    _picker.tag = 1;
    _picker.pickerType = NumPickerTypeNormal;
    _picker.numberText = textField.text;
    
    if (!_popoverController) {
        if (kIsiPhone) {
            _popoverController = [[WEPopoverController alloc] initWithContentViewController:_picker];
        } else {
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:_picker];
        }
    }
    
    if (!kIsiPhone) {
        if (kSystemVersionOfCurrentDevice >= 7.0) {
            // 更改iOS7默认样式
            [(UIPopoverController *)_popoverController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
        } else {
            [(UIPopoverController *)_popoverController setPopoverBackgroundViewClass:nil];
        }
    }
    
    [_popoverController setContentViewController:_picker];
    [_popoverController setPopoverContentSize:_picker.pickerSize];
    
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [self.contentView convertRect:textField.frame toView:mainCtrl.view];
        [_popoverController setParentView:mainCtrl.view];
        [_popoverController presentPopoverFromRect:showRect
                                            inView:mainCtrl.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    } else {
        [_popoverController presentPopoverFromRect:textField.frame
                                            inView:self.contentView
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    }
}
//时间选择器
-(void) timePickerCreate: (UITextField *)textField
{
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    actionSheet.tag = 1;
    NSString *timeStr = textField.text;
    
    if (0 == timeStr.length)
    {
        timeStr = [NSString dateToNSString:[NSDate date] withFormat:@"HH:mm"];
    }
    
    //时间选择器
    _timePicker = [[CustomTimePicker alloc]initWithLastTimeString:timeStr];
    if (kIsiPhone) {
        _timePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
    } else {
        _timePicker.frame = CGRectMake(-25.0, 0.0, 320.0, 216.0);
    }
    _timePicker.backgroundColor = [UIColor clearColor];
    _timePicker.tag = textField.tag;
    [actionSheet addSubview:_timePicker];
    
    if (kIsiPhone) {
        [actionSheet showInView:self.window];
    } else {
        [actionSheet showFromRect:textField.frame inView:self.contentView animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1:// timepicker
        {
            //确定
            if (0 == buttonIndex)
            {
                UITextField *textField = (UITextField *)[self.contentView viewWithTag:_timePicker.tag];
                textField.text = _timePicker.selectedTimeStr;
                
                // fromtime
                if (_timePicker.tag == 1)
                {
                    [_timePriceDict setObject:_timePicker.selectedTimeStr forKey:@"fromTime"];
                }
                else if (_timePicker.tag == 2)// totime
                {
                    [_timePriceDict setObject:_timePicker.selectedTimeStr forKey:@"toTime"];
                }
                
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _isTextFieldClearButtonClick = YES;
    if (textField == _startTimeTextField)
    {
        [_timePriceDict setObject:@"" forKey:@"fromTime"];
    }
    else if (textField == _endTimeTextField)// totime
    {
        [_timePriceDict setObject:@"" forKey:@"toTime"];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _startTimeTextField || textField == _endTimeTextField)//时间
    {
        if (self.hideKeyboardBlock)
        {
            self.hideKeyboardBlock();
        }
        
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        
        [self timePickerCreate: textField];
        return NO;
    }
    else if (textField.tag == 3)//优惠
    {
        if (self.hideKeyboardBlock)
        {
            self.hideKeyboardBlock();
        }
        
        [self numberPicker:textField];
        return NO;
    }
    
    return YES;
}



#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    _priceTextField.text = number;
    [_timePriceDict setObject:number forKey:@"offer"];
    [_popoverController dismissPopoverAnimated:YES];
}
@end
