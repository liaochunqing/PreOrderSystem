//
//  CustomDatePicker.h
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-6-10.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomDatePicker : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray *yearArray;//保存年份
    NSMutableArray *timeLevelArray;
    int currentYear;//当前年
    int currentMonth;//当前月份
}

@property (nonatomic, strong) NSMutableArray *selectedDateArray;//保存选择的时间
@property (nonatomic, weak) IBOutlet UIPickerView *customPickerView;

- (void)upateViewWithDateArray:(NSArray *)dateArray;

@end
