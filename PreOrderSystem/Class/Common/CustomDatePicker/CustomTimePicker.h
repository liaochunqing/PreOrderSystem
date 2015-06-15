//
//  CustomTimePicker.h
//  PreOrderSystem
//
//  Created by sWen on 13-6-17.
//
//

#import <UIKit/UIKit.h>

@interface CustomTimePicker : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UIPickerView *customPickerView;
@property (nonatomic, strong) NSString *selectedTimeStr;//保存选择的时间

- (id)initWithLastTimeString:(NSString *)timeStr;

@end
