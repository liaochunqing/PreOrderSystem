//
//  DishDetailTitleView.m
//  PreOrderSystem
//
//  Created by sWen on 13-7-3.
//
//

#import "DishDetailTitleView.h"
#import "PSAlertView.h"
#import "NsstringAddOn.h"
#import "Constants.h"
#import "PSPopoverBckgroundView.h"
#import "WEPopoverController.h"
#import "MainViewController.h"

#define kMinCarryfee 0
#define kMaxCarryfee 1000
#define kCarryfeeTextfieldTag 1000

@interface DishDetailTitleView ()

- (IBAction)modifyBtnClicked:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)trueBtnClicked:(id)sender;

@end

@implementation DishDetailTitleView

- (id)initWithCarryfee:(NSString *)feeStr withOrderStatus:(int)orderStatus withDeliveryType:(int)deliveryType
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"DishDetailTitleView" owner:self options:Nil]lastObject];
    if (self)
    {
        [self addLocalizedString];
        carryfeeStr = [NSString stringWithFormat:@"%@",[NSString trimmingZeroInPrice:feeStr]];
        self.carryfeeTextField.text = carryfeeStr;
        self.modiftButton.hidden = (1 == deliveryType)?YES:(0 == orderStatus )?NO:YES;
    }
    return self;
}

- (IBAction)modifyBtnClicked:(id)sender
{
    self.modiftButton.hidden = YES;
    self.handleImageViewBg.hidden = NO;
    self.textFieldImageViewBg.hidden = NO;
    self.carryfeeTextField.hidden = NO;
    self.cancelButton.hidden = NO;
    self.trueButton.hidden = NO;
    self.carryfeeTextField.text = carryfeeStr;
}

- (IBAction)cancelBtnClicked:(id)sender
{
    self.modiftButton.hidden = NO;
    self.handleImageViewBg.hidden = YES;
    self.textFieldImageViewBg.hidden = YES;
    self.cancelButton.hidden = YES;
    self.trueButton.hidden = YES;
    self.carryfeeTextField.hidden = YES;
}

- (IBAction)trueBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(modifyCarryfee:)])
    {
        [self.delegate modifyCarryfee:self.carryfeeTextField.text];
        
        self.modiftButton.hidden = NO;
        self.handleImageViewBg.hidden = YES;
        self.textFieldImageViewBg.hidden = YES;
        self.cancelButton.hidden = YES;
        self.trueButton.hidden = YES;
        self.carryfeeTextField.hidden = YES;
    }
}

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"inventory");
    self.carryfeeTextField.text = kLoc(@"click_to_input_price");
    [self.modiftButton setTitle:kLoc(@"modify_carry_fee") forState:UIControlStateNormal];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
    [self.cancelButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NumPicker *picker = [[NumPicker alloc] init];
    picker.delegate = self;
    picker.tag = kCarryfeeTextfieldTag;
    picker.minimumNum = kMinCarryfee;
    picker.maximumNum = kMaxCarryfee;
    picker.pickerType = NumPickerTypeWithDecimal;
    picker.numberText = self.carryfeeTextField.text;
    
    if (!self.popController) {
        if (kIsiPhone) {
            self.popController = [[WEPopoverController alloc] initWithContentViewController:picker];
        } else {
            self.popController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
    }
    
    if (!kIsiPhone) {
        if (kSystemVersionOfCurrentDevice >= 7.0) {
            // 更改iOS7默认样式
            [(UIPopoverController *)self.popController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
        } else {
            [(UIPopoverController *)self.popController setPopoverBackgroundViewClass:nil];
        }
    }
    
    [self.popController setContentViewController:picker];
    [self.popController setPopoverContentSize:picker.pickerSize];
    
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [self convertRect:textField.frame toView:mainCtrl.view];
        [self.popController setParentView:mainCtrl.view];
        [self.popController presentPopoverFromRect:showRect
                                            inView:mainCtrl.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    } else {
        [self.popController presentPopoverFromRect:textField.frame
                                            inView:self
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    }
    
    return NO;
}

#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    [self.popController dismissPopoverAnimated:YES];
    CGFloat tempNumber = [number floatValue];
    NSString *tempStr = [NSString stringWithFormat:@"%.2f",tempNumber];
    self.carryfeeTextField.text = [NSString stringWithFormat:@"%@",[NSString trimmingZeroInPrice:tempStr]];
}

- (void)NumPicker:(NumPicker*)picker didPickedOverflowNumber:(NSString*)number
{
    [PSAlertView showWithMessage:kLoc(@"please_enter_from_0_to_1000")];
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
