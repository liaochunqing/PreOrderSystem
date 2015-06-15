//
//  EditArrangCategoryViewControllerCell.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-8.
//
//

#import "EditArrangCategoryViewControllerCell.h"
#import "NsstringAddOn.h"
#import "QueueCategoryDataClass.h"
#import "UITextFieldAddition.h"

@interface EditArrangCategoryViewControllerCell ()

- (IBAction)deleteButtonPressed:(UIButton *)sender;

@end

@implementation EditArrangCategoryViewControllerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateEditArrangCategoryCell:(NSDictionary *)categoryDict;
{
    self.backgroundColor = [UIColor clearColor];
    
    // 添加关闭按钮
    [self.minCapacityField bindCloseButton];
    [self.maxCapacityField bindCloseButton];
    
    QueueCategoryDataClass *dataClass = [[QueueCategoryDataClass alloc] initWithQueueCategoryData:categoryDict];
    self.categoryTextField.text = dataClass.categoryName;
    self.minCapacityField.text = [NSString stringWithFormat:@"%d", dataClass.minCapacity];
    self.maxCapacityField.text = [NSString stringWithFormat:@"%d", dataClass.maxCapacity];
}

- (IBAction)deleteButtonPressed:(UIButton *)sender
{
    [self hideKeyBoard];
    [self performSelector:@selector(deleteCell) withObject:nil afterDelay:0.5];
}

- (void)deleteCell
{
    if ([self.delegate respondsToSelector:@selector(deleteArrangCategory:)])
    {
        [self.delegate deleteArrangCategory:self];
    }
}

- (void)hideKeyBoard
{
    [self.categoryTextField resignFirstResponder];
    [self.maxCapacityField resignFirstResponder];
    [self.minCapacityField resignFirstResponder];
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //键盘输入的界面调整
    if ([self.delegate respondsToSelector:@selector(moveViewUpWhenKeyboardShow:)])
    {
        [self.delegate moveViewUpWhenKeyboardShow:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //cell修改的内容
    if ([self.delegate respondsToSelector:@selector(ArrangCategoryChange:withNewCategory:withNewMinCapacity:withNewMaxCapacity:)])
    {
        NSString *nameStr = [NSString getStrWithoutWhitespace:self.categoryTextField.text];
        if ([NSString strIsEmpty:nameStr])
        {
            nameStr = @"";
        }
        [self.delegate ArrangCategoryChange:self withNewCategory:nameStr withNewMinCapacity:[self.minCapacityField.text integerValue] withNewMaxCapacity:[self.maxCapacityField.text integerValue]];
    }
    //键盘输入的界面调整
    if ([self.delegate respondsToSelector:@selector(moveViewBackWhenKeyboardHide:)])
    {
        [self.delegate moveViewBackWhenKeyboardHide:self];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.minCapacityField == textField || self.maxCapacityField == textField)
    {
        if ((![NSString isValidateNumber:string]) || range.location >= kArrangCategoryCapacityLen)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

@end
