//
//  RemarkItemTableViewCell.m
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import "RemarkItemTableViewCell.h"

#define kItemNameLength 6

@interface RemarkItemTableViewCell ()
{
    
}

- (IBAction)deleteButtonPressed:(UIButton *)sender;

@end

@implementation RemarkItemTableViewCell

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

- (void)updateViewAfterGetData:(NSString *)remarkNameStr
{
    self.backgroundColor = [UIColor clearColor];
    self.nameTextField.text = remarkNameStr;
}

- (IBAction)deleteButtonPressed:(UIButton *)sender
{
    [self.nameTextField resignFirstResponder];
    [self performSelector:@selector(deleteCell) withObject:nil afterDelay:0.3];
}

- (void)deleteCell
{
    if ([self.delegate respondsToSelector:@selector(deleteRemarkItem:)])
    {
        [self.delegate deleteRemarkItem:self];
    }
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSString *tempString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    textField.text = tempString;
    /*
    if (kItemNameLength < [textField.text length])
    {
        tempString = [textField.text substringToIndex:kItemNameLength];
    }
    else
    {
        tempString = textField.text;
    }
     */
    
    //cell修改的内容
    if ([self.delegate respondsToSelector:@selector(remarkItemChange:withNewItem:)])
    {
        [self.delegate remarkItemChange:self withNewItem:tempString];
    }
    
    return YES;
}
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= kItemNameLength)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
*/
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
