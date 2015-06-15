//
//  EditDiscountTableViewCell.m
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import "EditDiscountTableViewCell.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "PSPopoverBckgroundView.h"
#import "WEPopoverController.h"
#import "MainViewController.h"
#import "OfflineManager.h"
#import "CookbookPriceDataClass.h"
@implementation EditDiscountTableViewCell

- (void)awakeFromNib
{
    self.CustomPrice.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteBtnPress:(id)sender
{
    
}

- (void)showNumPicker:(UITextField *)textField
{
    if (!_picker)
    {
        _picker = [[NumPicker alloc] init];
    }
    _picker.delegate = self;
    _picker.pickerType = NumPickerTypeWithDishPrice;
    _picker.numberText = textField.text;
    
    if (!self.popoverController) {
        if (kIsiPhone) {
            self.popoverController = [[WEPopoverController alloc] initWithContentViewController:_picker];
        } else {
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:_picker];
        }
    }
    
    if (!kIsiPhone) {
        if (kSystemVersionOfCurrentDevice >= 7.0) {
            // 更改iOS7默认样式
            [(UIPopoverController *)self.popoverController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
        } else {
            [(UIPopoverController *)self.popoverController setPopoverBackgroundViewClass:nil];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.CustomPrice)
    {
        if ([_delegate respondsToSelector:@selector(EditDiscountTableViewCellDidBeginEditingPrice:)])
        {
            [_delegate EditDiscountTableViewCellDidBeginEditingPrice:self];
        }
        [self performSelector:@selector(showNumPicker:) withObject:textField afterDelay:0.5];
        return NO;
    }
    return YES;
}

#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    
    float maxPrice = [self getMaxPrice:self.cookBook];
    if (number.floatValue > maxPrice)//指定价格不能比原价大,
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"指定价格不能比原价贵", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [_popoverController dismissPopoverAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(EditDiscountTableViewCell:didFinishEditingPrice:)])
    {
        [self.delegate EditDiscountTableViewCell:self didFinishEditingPrice:number];
    }
    self.CustomPrice.text = number;//[NSString stringWithFormat:@"%@ %@",[[OfflineManager sharedOfflineManager]getCurrencySymbol],number];
}

/**
 *  找出菜品最大价格
 *
 *  @param cook 菜品数据
 *
 *  @return 最大价格
 */
- (CGFloat)getMaxPrice:(CookbookDataClass *)cook
{
    CookbookPriceDataClass *firstPrice = (CookbookPriceDataClass *)[cook.priceArr objectAtIndex:0];
    float maxPrice = firstPrice.price;
    for (CookbookPriceDataClass *price in cook.priceArr)
    {
        if (maxPrice < price.price)
        {
            maxPrice = price.price;
        }
    }
    return maxPrice;
}

@end
