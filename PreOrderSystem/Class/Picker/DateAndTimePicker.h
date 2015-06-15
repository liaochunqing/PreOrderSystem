//
//  DateAndTimePicker.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
	DateAndTimePickerTypeDate = 0,
	DateAndTimePickerTypeTime,
	DateAndTimePickerTypeDateAndTime
} DateAndTimePickerType;
@class DateAndTimePicker;
@protocol DateAndTimePickerDelegate <NSObject>
-(void)DateAndTimePicker:(DateAndTimePicker*)picker didPickedDate:(NSDate*)date;

@end

@interface DateAndTimePicker : UIViewController{
    __weak id <DateAndTimePickerDelegate> delegate;
    __weak UIDatePicker *datePicker;
    __weak UIButton *trueButton;
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign, readwrite) NSInteger tag;
//设置Picker的类型：日期/时间/日期＋时间
@property (nonatomic, assign, readwrite) NSInteger PickerType;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minimumDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *trueButton;

@end
