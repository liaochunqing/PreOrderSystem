//
//  NumPicker.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
	NumPickerTypeNormal = 0,
	NumPickerTypeWithDishPrice,
    NumPickerTypeWithDishQuantity,
    NumPickerTypeWithDecimal
} NumPickerType;

@class NumPicker;
@protocol NumPickerDelegate <NSObject>
@optional
//选取了正确的数值
-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number;
//选取了超出限制的数值（若设置了最小值minimumNum与最大值maximumNum）
-(void)NumPicker:(NumPicker*)picker didPickedOverflowNumber:(NSString*)number;
@end

@interface NumPicker : UIViewController{
    __weak id <NumPickerDelegate> delegate;
    __weak UILabel *numberTextLabel;
    __weak UIButton *dotButton;
    __weak UIButton *trueButton;
    __weak UIButton *deleteButton;
    __weak UIImageView *headImageView;
    __weak UIButton *num0Button;
    __weak UIButton *num1Button;
    __weak UIButton *num2Button;
    __weak UIButton *num3Button;
    __weak UIButton *num4Button;
    __weak UIButton *num5Button;
    __weak UIButton *num6Button;
    __weak UIButton *num7Button;
    __weak UIButton *num8Button;
    __weak UIButton *num9Button;
    
    //int pickerType;
    BOOL isFirst;
}

@property(nonatomic, weak) id delegate;
@property(nonatomic, assign, readwrite) NSInteger tag;
@property(nonatomic, assign, readwrite) NSInteger minimumNum;
@property(nonatomic, assign, readwrite) NSInteger maximumNum;
@property(nonatomic, strong) NSString *numberText;
@property(nonatomic, assign, readwrite) NSInteger pickerType;
@property(nonatomic, weak) IBOutlet UILabel *numberTextLabel;
@property(nonatomic, weak) IBOutlet UIButton *dotButton;
@property(nonatomic, weak) IBOutlet UIButton *trueButton;
@property(nonatomic, weak) IBOutlet UIButton *deleteButton;
@property(nonatomic, weak) IBOutlet UIImageView *headImageView;
@property(nonatomic, weak) IBOutlet UIButton *num0Button;
@property(nonatomic, weak) IBOutlet UIButton *num1Button;
@property(nonatomic, weak) IBOutlet UIButton *num2Button;
@property(nonatomic, weak) IBOutlet UIButton *num3Button;
@property(nonatomic, weak) IBOutlet UIButton *num4Button;
@property(nonatomic, weak) IBOutlet UIButton *num5Button;
@property(nonatomic, weak) IBOutlet UIButton *num6Button;
@property(nonatomic, weak) IBOutlet UIButton *num7Button;
@property(nonatomic, weak) IBOutlet UIButton *num8Button;
@property(nonatomic, weak) IBOutlet UIButton *num9Button;


-(CGSize)pickerSize;
@end
