//
//  EditCuisineTableViewCell.m
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import "EditCuisineTableViewCell.h"
#import "NsstringAddOn.h"

//cell每行有3列
#define kRowNumberOfCell 3
#define kCuisineNameLength 6

@implementation EditCuisineTableViewCell

@synthesize delegate;
@synthesize lineImageView;
@synthesize deleteButton;
@synthesize cuisineTextField;

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

- (void)refreshCellAfterGetData:(NSDictionary *)dict
{
    self.backgroundColor = [UIColor clearColor];
    //第一列
    if (0 != [dict count])
    {
        self.cuisineTextField.text = [dict objectForKey:@"name"];
    }
}


- (IBAction)deleteButtonPressed:(UIButton *)sender
{
    [self.cuisineTextField resignFirstResponder];
    [self performSelector:@selector(deleteCell) withObject:nil afterDelay:0.3];
}

- (void)deleteCell
{
    if ([delegate respondsToSelector:@selector(deleteCuisine:)])
    {
        [delegate deleteCuisine:self];
    }
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //键盘输入的界面调整
    if ([delegate respondsToSelector:@selector(moveViewUpWhenKeyboardShow:)])
    {
        [delegate moveViewUpWhenKeyboardShow:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //截取字符串
    NSString *tempString = [NSString cutString:textField.text withMaxLengthOfStr:kCuisineNameLength];
    textField.text = tempString;
    
    //cell修改的内容
    if ([delegate respondsToSelector:@selector(cuisineNameChange:withNewCuisineName:)])
    {
        [delegate cuisineNameChange:self withNewCuisineName:tempString];
    }
    //键盘输入的界面调整
    if ([delegate respondsToSelector:@selector(moveViewBackWhenKeyboardHide:)])
    {
        [delegate moveViewBackWhenKeyboardHide:self];
    }
    
    return YES;
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= kCuisineNameLength)
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
