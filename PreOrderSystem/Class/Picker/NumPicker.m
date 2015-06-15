//
//  NumPicker.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NumPicker.h"
#import "PSAlertView.h"
#import "Constants.h"

@interface NumPicker (Private)
//数字按键点击
-(IBAction)numButtonPressed:(UIButton*)sender;
//小数点按键点击
-(IBAction)dotButtonPressed:(UIButton*)sender;
//归零按键点击
-(IBAction)ceButtonPressed:(UIButton*)sender;
-(IBAction)doneButtonPressed:(UIButton*)sender;
@end

@implementation NumPicker
@synthesize delegate;
@synthesize tag;
@synthesize numberText;
@synthesize pickerType;
@synthesize minimumNum;
@synthesize maximumNum;
@synthesize numberTextLabel;
@synthesize dotButton;
@synthesize trueButton;
@synthesize deleteButton;
@synthesize headImageView;
@synthesize num0Button,num1Button,num2Button,num3Button,num4Button,num5Button,num6Button,num7Button,num8Button,num9Button;

#pragma mark LIFE CYCLE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addLocalizedString];
    
    switch (pickerType) {
        case NumPickerTypeNormal:{
            dotButton.enabled = NO;
            break;
        }
        case NumPickerTypeWithDishPrice:{
            dotButton.enabled = YES;
            break;
        }
        case NumPickerTypeWithDishQuantity:{
            dotButton.enabled = NO;
            break;
        }
        case NumPickerTypeWithDecimal:
        {
            dotButton.enabled = YES;
            break;
        }
    }
    
    if (numberText!=nil && ![numberText isEqualToString:@""]) {
        numberTextLabel.text = numberText;
    }
    else {
        numberTextLabel.text = @"0";
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    isFirst = YES;
    switch (pickerType) {
        case NumPickerTypeNormal:{
            dotButton.enabled = NO;
            break;
        }
        case NumPickerTypeWithDishPrice:{
            dotButton.enabled = YES;
            break;
        }
        case NumPickerTypeWithDishQuantity:{
            dotButton.enabled = NO;
            break;
        }
        case NumPickerTypeWithDecimal:
        {
            dotButton.enabled = YES;
            break;
        }
    }
    
    if (numberText!=nil && ![numberText isEqualToString:@""]) {
        numberTextLabel.text = numberText;
    }
    else {
        numberTextLabel.text = @"0";
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
       [self setView:nil];
    }
}

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"===NumPicker,dealloc===");
#endif
}

#pragma mark -
#pragma mark PUBLIC METHODS
-(CGSize)pickerSize{
    return CGSizeMake(289, 346);
}

#pragma mark PRIVATE METHODS
//数字按键点击
-(IBAction)numButtonPressed:(UIButton*)sender
{
    int numberLength = 11;
    if (pickerType == NumPickerTypeWithDishPrice)
    {
        //价格做多可以输入7位，包括.和小数部分
        numberLength = 7;
    }
    else if (pickerType == NumPickerTypeWithDishQuantity)
    {
        numberLength = 3;
    }
    else if (pickerType == NumPickerTypeWithDecimal)
    {
        numberLength = 7;
    }
    
    int nextValue = sender.tag;
    if ([numberTextLabel.text length] < numberLength)
    {
        if ([numberTextLabel.text isEqualToString:@"0"])
        {
            if (nextValue!=0)
            {
                numberTextLabel.text = [NSString stringWithFormat:@"%i", nextValue];
                isFirst = NO;
            }
        }
        else
        {
            if (isFirst == YES)
            {
                numberTextLabel.text = [NSString stringWithFormat:@"%i", nextValue];
                isFirst = NO;
            }
            else
            {
                numberTextLabel.text = [NSString stringWithFormat:@"%@%i",numberTextLabel.text, nextValue];
            }
        }
        if (pickerType == NumPickerTypeWithDishPrice)
        {
            //两位小数点
            NSRange tempRange = [numberTextLabel.text rangeOfString:@"."];
            if (tempRange.location != NSNotFound)
            {
                NSString *tempString = [numberTextLabel.text substringFromIndex:tempRange.location + 1];
                
                if (2 < [tempString length])
                {
                    NSRange subRange = NSMakeRange(tempRange.location + 1, 2);
                    numberTextLabel.text = [NSString stringWithFormat:@"%@.%@",[numberTextLabel.text substringToIndex:tempRange.location], [numberTextLabel.text substringWithRange:subRange]];
                    return;
                }
            }
        }
    }
    else
    {
        if (isFirst == YES)
        {
            numberTextLabel.text = [NSString stringWithFormat:@"%i", nextValue];
            isFirst = NO;
        }
    }
}

//小数点按键点击
-(IBAction)dotButtonPressed:(UIButton*)sender
{
    if ([numberTextLabel.text length] < 7 && (pickerType == NumPickerTypeWithDishPrice || pickerType == NumPickerTypeWithDecimal))
    {
        if ([numberTextLabel.text rangeOfString:@"."].location != NSNotFound)
        {
            return;
        }
        if (0 != [numberTextLabel.text length])
        {
            numberTextLabel.text = [NSString stringWithFormat:@"%@.", numberTextLabel.text];
        }
    }
}


//归零按键点击
-(IBAction)ceButtonPressed:(UIButton*)sender{
    numberTextLabel.text = @"0";
}


//删除按键点击
-(IBAction)deleteButtonPressed:(UIButton*)sender
{
    NSString *text = numberTextLabel.text;
    if ([text length]>0)
    {
//        if ([numberTextLabel.text isEqualToString:@"0"] || [text length]==1)
//        {
//            numberTextLabel.text = @"0";
//        }
        if ( [text length] == 1)
        {
            numberTextLabel.text = @"";
        }
        else
        {
            numberTextLabel.text = [numberTextLabel.text substringWithRange:NSMakeRange(0, [text length]-1)];
        }
    }
    else
    {
        
    }
}


-(IBAction)doneButtonPressed:(UIButton*)sender{
    int pickedNum = [numberTextLabel.text intValue];
    
    //判断点取的数字是否超出限制
    if (minimumNum!=maximumNum) {
        if (pickedNum>=minimumNum && pickedNum<=maximumNum) {
            if ([delegate respondsToSelector:@selector(NumPicker:didPickedNumber:)]) {
                [delegate NumPicker:self didPickedNumber:numberTextLabel.text];
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(NumPicker:didPickedOverflowNumber:)]) {
                [delegate NumPicker:self didPickedOverflowNumber:numberTextLabel.text];
            }
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(NumPicker:didPickedNumber:)]) {
            [delegate NumPicker:self didPickedNumber:numberTextLabel.text];
        }
    }
}

- (void)addLocalizedString
{
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
}

@end
