//
//  CustomDatePicker.m
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-6-10.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "CustomDatePicker.h"
#import "NsstringAddOn.h"

@implementation CustomDatePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"CustomDatePicker" owner:self options:Nil]lastObject];
    if (self)
    {
        self.frame = frame;
    }
    return self;
}

- (void)upateViewWithDateArray:(NSArray *)dateArray
{
    self.selectedDateArray = [[NSMutableArray alloc]initWithCapacity:1];
    timeLevelArray = [[NSMutableArray alloc]initWithCapacity:3];
    [timeLevelArray addObject:kLoc(@"noon")];
    [timeLevelArray addObject:kLoc(@"evening")];
    [timeLevelArray addObject:kLoc(@"all_day")];
    
    NSString *nowTimeStr = [NSString dateToNSString:[NSDate date] withFormat:@"yyyy/MM/dd"];
    NSArray *timeComponent = [nowTimeStr componentsSeparatedByString:@"/"];
    currentYear = [[timeComponent objectAtIndex:0]integerValue];
    currentMonth = [[timeComponent objectAtIndex:1]integerValue];
    
    yearArray = [[NSMutableArray alloc]initWithCapacity:3];
    int lastYear = [[timeComponent objectAtIndex:0]integerValue] - 1;
    int nextYear = [[timeComponent objectAtIndex:0]integerValue] + 1;
    [yearArray addObject:[NSString stringWithFormat:@"%d",lastYear]];
    [yearArray addObject:[timeComponent objectAtIndex:0]];
    [yearArray addObject:[NSString stringWithFormat:@"%d",nextYear]];
    
    //上次选择的时间
    if (0 != [dateArray count])
    {
        int yearCount = [yearArray count];
        for (int j = 0; j < yearCount; j ++)
        {
            if (YES == [[dateArray objectAtIndex:0]isEqualToString:[yearArray objectAtIndex:j]])
            {
                [self.customPickerView selectRow:j inComponent:0 animated:YES];
                break;
            }
        }
        [self.customPickerView selectRow:[[dateArray objectAtIndex:1]integerValue] -1 inComponent:1 animated:YES];
        [self.customPickerView selectRow:[[dateArray objectAtIndex:2]integerValue] -1 inComponent:2 animated:YES];
        int tiemLevelCount = [timeLevelArray count];
        for (int j = 0; j < tiemLevelCount; j ++)
        {
            if (YES == [[dateArray objectAtIndex:3]isEqualToString:[timeLevelArray objectAtIndex:j]])
            {
                [self.customPickerView selectRow:j inComponent:3 animated:YES];
                break;
            }
        }
        //选择时间
        [self.selectedDateArray addObjectsFromArray:dateArray];
    }
    else
    {
        //上次时间为空时，默认为当前时间
        [self.customPickerView selectRow:1 inComponent:0 animated:YES];
        [self.customPickerView selectRow:[[timeComponent objectAtIndex:1]integerValue] -1 inComponent:1 animated:YES];
        [self.customPickerView selectRow:[[timeComponent objectAtIndex:2]integerValue] -1 inComponent:2 animated:YES];
        [self.customPickerView selectRow:2 inComponent:3 animated:YES];
        //选择时间 2013-6-13 全天
        NSString *yearStr = [timeComponent objectAtIndex:0];
        NSString *monthStr = [NSString stringWithFormat:@"%d", [[timeComponent objectAtIndex:1]integerValue]];
        NSString *dayStr = [NSString stringWithFormat:@"%d", [[timeComponent objectAtIndex:2]integerValue]];
        NSString *timeLevelStr = [timeLevelArray objectAtIndex:2];
        [self.selectedDateArray addObject:yearStr];
        [self.selectedDateArray addObject:monthStr];
        [self.selectedDateArray addObject:dayStr];
        [self.selectedDateArray addObject:timeLevelStr];
    }
    [self.customPickerView reloadAllComponents];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    BOOL isLeapYear = NO;//用来判断是否是润年
    if((currentYear % 400 == 0)||((currentYear % 4 == 0)&&(currentYear % 100 != 0)))
    {
        isLeapYear = YES;
    }
    int number = 3;
    if ( 0 == component)
    {
        number = 3;
    }
    else if(1 == component)
    {
        number = 12;
    }
    else if(2 == component)
    {
        if ((1 == currentMonth) || (3 == currentMonth) ||(5 == currentMonth) || (7 == currentMonth) ||(8 == currentMonth) || (10 == currentMonth) || (12 == currentMonth))
        {
            number = 31;
        }
        else if((4 == currentMonth) ||(6 == currentMonth) || (9 == currentMonth) ||(11 == currentMonth))
        {
            number = 30;
        }
        else
        {
            if (isLeapYear == YES)
            {
                number = 29;
            }
            else
            {
                number = 28;
            }
        }
    }
    else
    {
        number = 3;
    }
    
	return number;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 4;
}

#pragma mark UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *returnStr = @"";
    if (0 == component)
    {
        returnStr = [yearArray objectAtIndex:row];
    }
    else if(1 == component)
    {
        returnStr = [NSString stringWithFormat:@"%d",row + 1];
    }
    else if(2 == component)
    {
        returnStr = [NSString stringWithFormat:@"%d",row + 1];
    }
    else
    {
        returnStr = [timeLevelArray objectAtIndex:row];
    }
    //选择的蓝色
    UIColor *textColor = [UIColor blackColor];
    if (component < [self.selectedDateArray count])
    {
        if (YES == [[self.selectedDateArray objectAtIndex:component]isEqualToString:returnStr])
        {
            textColor = [UIColor colorWithRed:0 green:87.0/255.0 blue:240.0/255.0 alpha:1.0];
        }
    }

    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    aLabel.textAlignment = UITextAlignmentCenter;
    aLabel.textColor = textColor;
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.font = [UIFont boldSystemFontOfSize:20];
    aLabel.text = returnStr;
    
    return aLabel;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 60.0;
    
	if (component == 0)
    {
		componentWidth = 60.0;
    }
    else if(1 == component)
    {
        componentWidth = 60.0;
    }
    else if(2 == component)
    {
        componentWidth = 60.0;
    }
	else
    {
		componentWidth = 60.0;
    }
    
	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //时间格式为2013-06-10 全天
    NSString *yearStr = [yearArray objectAtIndex:[pickerView selectedRowInComponent:0]];
    NSString *monthStr = [NSString stringWithFormat:@"%d",[pickerView selectedRowInComponent:1] + 1];
    NSString *dayStr = [NSString stringWithFormat:@"%d",[pickerView selectedRowInComponent:2] + 1];;
    NSString *timeLevelStr = [timeLevelArray objectAtIndex:[pickerView selectedRowInComponent:3]];
    
    [self.selectedDateArray removeAllObjects];
    [self.selectedDateArray addObject:yearStr];
    [self.selectedDateArray addObject:monthStr];
    [self.selectedDateArray addObject:dayStr];
    [self.selectedDateArray addObject:timeLevelStr];
    //选中变蓝
    [self.customPickerView reloadComponent:component];
}

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"===CustomDatePicker,dealloc===");
#endif
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
