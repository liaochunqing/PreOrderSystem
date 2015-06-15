//
//  DishCardNewDetailTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-7-16.
//
//

#import "DishCardNewDetailTableViewCell.h"
#import "Constants.h"
#import "PSPopoverBckgroundView.h"
#import "PackageMemberDataModel.h"
#import "WEPopoverController.h"
#import "MainViewController.h"
#import "PSAlertView.h"

@implementation DishCardNewDetailTableViewCell
{
    id _info;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateCellInfo:(id) info
{
    _info = info;
    self.numberTextField.delegate = self;
    
    if ([info isKindOfClass:[CookbookDataClass class]])
    {
        CookbookDataClass *cookbook = (CookbookDataClass *)info;
        self.nameLabel.text = cookbook.cookbookName;
        self.numberTextField.text = [NSString stringWithFormat:@"%d", cookbook.quantity];
    }
    else if ([info isKindOfClass:[PackageMemberDataModel class]])
    {
        PackageMemberDataModel *packageMember = (PackageMemberDataModel *)info;
        self.nameLabel.text = packageMember.memberName;
        self.numberTextField.text = [NSString stringWithFormat:@"%d", packageMember.quantity];
    }
}

- (void)numberPicker:(UITextField *)textField
{
    if (!_picker)
    {
        _picker = [[NumPicker alloc] init];
    }
    _picker.delegate = self;
    _picker.tag = 1;
    _picker.pickerType = NumPickerTypeWithDishPrice;
    _picker.numberText = textField.text;
    _picker.minimumNum = 0;
    _picker.maximumNum = 1000;
    
    if (!_popoverController) {
        if (kIsiPhone) {
            _popoverController = [[WEPopoverController alloc] initWithContentViewController:_picker];
        } else {
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:_picker];
        }
    }
    
    if (!kIsiPhone) {
        if (kSystemVersionOfCurrentDevice >= 7.0) {
            // 更改iOS7默认样式
            [(UIPopoverController *)_popoverController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
        } else {
            [(UIPopoverController *)_popoverController setPopoverBackgroundViewClass:nil];
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

#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    [_popoverController dismissPopoverAnimated:YES];
    self.numberTextField.text = number;
    
    
    if ([_info isKindOfClass:[CookbookDataClass class]])
    {
        CookbookDataClass *cookbook = (CookbookDataClass *)_info;
        cookbook.quantity = [number integerValue];
    }
    else if ([_info isKindOfClass:[PackageMemberDataModel class]])
    {
        PackageMemberDataModel *packageMember = (PackageMemberDataModel *)_info;
        packageMember.quantity = [number integerValue];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(DishCardNewDetailTableViewCell:changeChooseNumber:)]) {
        [self.delegate DishCardNewDetailTableViewCell:self changeChooseNumber:[number integerValue]];
    }


}

- (void)NumPicker:(NumPicker*)picker didPickedOverflowNumber:(NSString*)number
{
    [PSAlertView showWithMessage:NSLocalizedString(@"请输入0~1000", nil)];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.numberTextField)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(DishCardNewDetailTableViewCell:hideKeyboard:)])
        {
            [self.delegate DishCardNewDetailTableViewCell:self hideKeyboard:YES];
        }
        
        [self numberPicker:textField];
        return NO;
    }
    
    return YES;
}

@end
