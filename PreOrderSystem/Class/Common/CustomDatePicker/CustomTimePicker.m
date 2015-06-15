//
//  CustomTimePicker.m
//  PreOrderSystem
//
//  Created by sWen on 13-6-17.
//
//

#import "CustomTimePicker.h"
#import "NsstringAddOn.h"

@implementation CustomTimePicker

- (id)initWithLastTimeString:(NSString *)lastTimeStr
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"CustomTimePicker" owner:self options:Nil]lastObject];
    if (self)
    {
        //当前时间,24小时制
        NSString *nowTimeStr = [NSString dateToNSString:[NSDate date] withFormat:@"HH:mm"];
        NSArray *nowTimeComponent = [nowTimeStr componentsSeparatedByString:@":"];
        //上次选择的时间
        NSArray *lastTimeComponent = [lastTimeStr componentsSeparatedByString:@":"];
        
        if (2 == [nowTimeComponent count])
        {
            NSString *nowHourStr = [nowTimeComponent objectAtIndex:0];
            NSString *nowMinuteStr = [nowTimeComponent objectAtIndex:1];
            
            //上次选择的时间
            if (2 == [lastTimeComponent count])
            {
                NSString *lastHourStr = [lastTimeComponent objectAtIndex:0];
                NSString *lastMinuteStr = [lastTimeComponent objectAtIndex:1];
                
                [self.customPickerView selectRow:[lastHourStr integerValue] inComponent:0 animated:YES];
                [self.customPickerView selectRow:[lastMinuteStr integerValue] inComponent:1 animated:YES];
                //默认一个选择时间
                self.selectedTimeStr = [NSString stringWithFormat:@"%@:%@",lastHourStr,lastMinuteStr];
            }
            else
            {
                //上次时间为空时，默认为当前时间
                [self.customPickerView selectRow:[nowHourStr integerValue] inComponent:0 animated:YES];
                [self.customPickerView selectRow:[nowMinuteStr integerValue] inComponent:1 animated:YES];
                //默认一个选择时间
                self.selectedTimeStr = [NSString stringWithFormat:@"%@:%@",nowHourStr,nowMinuteStr];
            }
        }
        [self.customPickerView reloadAllComponents];
    }
    return self;
}

#pragma mark UIPickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    int number = 0;
    if ( 0 == component)
    {
        number = 24;
    }
    else if(1 == component)
    {
        number = 60;
    }
	return number;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

#pragma mark UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *returnStr = @"";
    if (10 > row)
    {
        returnStr = [NSString stringWithFormat:@"0%d",row];
    }
    else
    {
        returnStr = [NSString stringWithFormat:@"%d",row];
    }
 
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    aLabel.textAlignment = UITextAlignmentCenter;
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.font = [UIFont boldSystemFontOfSize:20];
    aLabel.text = returnStr;
    
    return aLabel;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 0.0;
    
	if (component == 0)
    {
		componentWidth = 60.0;
    }
    else if(1 == component)
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
    //时间格式为18:25
    int hour = [pickerView selectedRowInComponent:0];
    int minute = [pickerView selectedRowInComponent:1];
    NSString *hourStr = nil;
    NSString *minuteStr = @"";
    if (10 > hour)
    {
        hourStr = [NSString stringWithFormat:@"0%d",[pickerView selectedRowInComponent:0]];
    }
    else
    {
        hourStr = [NSString stringWithFormat:@"%d",[pickerView selectedRowInComponent:0]];
    }
    if (10 > minute)
    {
        minuteStr = [NSString stringWithFormat:@"0%d",[pickerView selectedRowInComponent:1]];
    }
    else
    {
        minuteStr = [NSString stringWithFormat:@"%d",[pickerView selectedRowInComponent:1]];
    }
    
    self.selectedTimeStr = [NSString stringWithFormat:@"%@:%@",hourStr,minuteStr];
    
#ifdef DEBUG
    NSLog(@"===CustomTimePicker,time:%@,%@,%@===",hourStr,minuteStr,self.selectedTimeStr);
#endif
}

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"===CustomTimePicker,dealloc===");
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
