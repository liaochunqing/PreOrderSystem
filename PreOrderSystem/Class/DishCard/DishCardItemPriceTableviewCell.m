//
//  DishCardItemPriceTableviewCell.m
//  PreOrderSystem
//
//  Created by AaronKwok on 13-4-16.
//
//

#import "DishCardItemPriceTableviewCell.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "PSPopoverBckgroundView.h"
#import "WEPopoverController.h"
#import "MainViewController.h"

#define kStyleLength 6

@interface DishCardItemPriceTableviewCell ()

- (IBAction)addItemButtonPressed:(id)sender;
- (IBAction)deleteItemButtonPressed:(id)sender;

@end

@implementation DishCardItemPriceTableviewCell
@synthesize delegate;
@synthesize tag;
@synthesize titleLabel;
@synthesize unitLabel;
@synthesize addItemButton;
@synthesize deleteItemButton;
@synthesize itemStyleTextfield;
@synthesize itemPriceTextfield;
@synthesize popoverController;

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===DishCardItemPriceTableviewCell,dealloc===");
#endif
}

-(void)updateCellInfo:(NSDictionary*)info
{
    if (info == nil)
    {
        return;
    }
    
    self.backgroundColor = [UIColor clearColor];
    [self addLocalizedString];
    
    if (tag==0)
    {
        titleLabel.hidden = NO;
        addItemButton.hidden = NO;
        deleteItemButton.hidden = YES;
    }
    else
    {
        titleLabel.hidden = YES;
        addItemButton.hidden = YES;
        deleteItemButton.hidden = NO;
    }
    
    itemStyleTextfield.text = [info objectForKey:@"style"];
    itemPriceTextfield.text = [NSString stringWithFormat:@"%@", [info objectForKey:@"price"]];
}

- (void)addLocalizedString
{
//    self.itemPriceTextfield.text = kLoc(@"(金额)", nil);
//    self.itemStyleTextfield.text = kLoc(@"(规格)", nil);
//    self.titleLabel.text = kLoc(@"价格 ：", nil);
//    self.unitLabel.text = kLoc(@"元", nil);
    
    self.itemPriceTextfield.text = [NSString stringWithFormat:@"(%@)",kLoc(@"money")];
    self.itemStyleTextfield.text = [NSString stringWithFormat:@"(%@)",kLoc(@"specification")];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"price")];
    self.unitLabel.text = kLoc(@"yuan");
}

-(IBAction)addItemButtonPressed:(id)sender
{
    [self.itemStyleTextfield resignFirstResponder];
    
    NSString *styleStr = [NSString getStrWithoutWhitespace:self.itemStyleTextfield.text];
    NSString *priceStr = [NSString getStrWithoutWhitespace:self.itemPriceTextfield.text];
    if ([NSString strIsEmpty:styleStr] || [NSString strIsEmpty:priceStr])
    {
        [PSAlertView showWithMessage:kLoc(@"please_fill_complete")];
        return;
    }
    if ([delegate respondsToSelector:@selector(dishCardItemPriceTableviewCell:withAddStyle:withAddPriceStr:)])
    {
        [self.delegate dishCardItemPriceTableviewCell:self withAddStyle:styleStr withAddPriceStr:priceStr];
    }
}

-(IBAction)deleteItemButtonPressed:(id)sender
{
    [self.itemStyleTextfield resignFirstResponder];
    
    if ([delegate respondsToSelector:@selector(DishCardItemPriceTableviewCellDidDeletedItem:)])
    {
        [delegate DishCardItemPriceTableviewCellDidDeletedItem:self];
    }
}

- (void)showNumPicker:(UITextField *)textField
{
    if (!picker)
    {
        picker = [[NumPicker alloc] init];
    }
    picker.delegate = self;
    picker.tag = tag;
    picker.pickerType = NumPickerTypeWithDishPrice;
    picker.numberText = textField.text;
    
    if (!self.popoverController)
    {
        if (kIsiPhone)
        {
            self.popoverController = [[WEPopoverController alloc] initWithContentViewController:picker];
        }
        else
        {
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
    }
    
    if (!kIsiPhone)
    {
        if (kSystemVersionOfCurrentDevice >= 7.0)
        {
            // 更改iOS7默认样式
            [(UIPopoverController *)self.popoverController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
        }
        else
        {
            [(UIPopoverController *)self.popoverController setPopoverBackgroundViewClass:nil];
        }
    }
    
    [popoverController setContentViewController:picker];
    [popoverController setPopoverContentSize:picker.pickerSize];
    
    if (kIsiPhone)
    {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [self.contentView convertRect:textField.frame toView:mainCtrl.view];
        [popoverController setParentView:mainCtrl.view];
        [popoverController presentPopoverFromRect:showRect
                                           inView:mainCtrl.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
    else
    {
        NSLog(@"pop");
        UIView *view = self.contentView;
        [popoverController presentPopoverFromRect:textField.frame
                                           inView:self.contentView
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.itemPriceTextfield)
    {
        if ([delegate respondsToSelector:@selector(DishCardItemPriceTableviewCellDidBeginEditingPrice:)])
        {
            [delegate DishCardItemPriceTableviewCellDidBeginEditingPrice:self];
        }
        
        [self performSelector:@selector(showNumPicker:) withObject:textField afterDelay:0.5];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.itemStyleTextfield == textField)
    {
        NSString *styleStr = [NSString getStrWithoutWhitespace:self.itemStyleTextfield.text];
        if ([delegate respondsToSelector:@selector(dishCardItemPriceTableviewCell:withStyleChanged:)])
        {
            [self.delegate dishCardItemPriceTableviewCell:self withStyleChanged:styleStr];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= kStyleLength && textField.tag == 1)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [itemStyleTextfield resignFirstResponder];
    return YES;
}

#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    [popoverController dismissPopoverAnimated:YES];
    itemPriceTextfield.text = number;
    
    NSString *priceStr = [NSString getStrWithoutWhitespace:self.itemPriceTextfield.text];
    if ([delegate respondsToSelector:@selector(dishCardItemPriceTableviewCell:withPriceStrChanged:)])
    {
        [self.delegate dishCardItemPriceTableviewCell:self withPriceStrChanged:priceStr];
    }
}
@end
