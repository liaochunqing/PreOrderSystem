//
//  QRCodeViewControllerCell.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-30.
//
//

#import "QRCodeViewControllerCell.h"
#import "NsstringAddOn.h"

#define kHousingDeskNameLength 12

@implementation QRCodeViewControllerCell

@synthesize delegate;
@synthesize bgImageView1;
@synthesize deleteButton1;
@synthesize nameTextField1;
@synthesize bgImageView2;
@synthesize deleteButton2;
@synthesize nameTextField2;
@synthesize cellTag;

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

- (void)refreshCellAfterGetData:(NSDictionary *)dict1 withSceond:(NSDictionary *)dict2
{
    self.backgroundColor = [UIColor clearColor];
    if (dict1 && 0 != [[dict1 objectForKey:@"name"] length])
    {
        nameTextField1.text = [dict1 objectForKey:@"name"];
        self.id1 = [[dict1 objectForKey:@"id"] intValue];
        self.deleteButton1.selected = [[dict1 objectForKey:@"selected"] boolValue];
    }
    if (dict2 && 0 != [[dict2 objectForKey:@"name"] length])
    {
        nameTextField2.text = [dict2 objectForKey:@"name"];
        self.id2 = [[dict2 objectForKey:@"id"] intValue];
        self.deleteButton2.selected = [[dict2 objectForKey:@"selected"] boolValue];
        bgImageView2.hidden = NO;
        nameTextField2.hidden = NO;
        deleteButton2.hidden = NO;
    }
    else
    {
        bgImageView2.hidden = YES;
        nameTextField2.hidden = YES;
        deleteButton2.hidden = YES;
    }
    
    [self.deleteButton1 setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateNormal];
    [self.deleteButton1 setImage:[UIImage imageNamed:@"more_item_checked.png"] forState:UIControlStateSelected];
    [self.deleteButton1 setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateSelected];
    
    [self.deleteButton2 setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateNormal];
    [self.deleteButton2 setImage:[UIImage imageNamed:@"more_item_checked.png"] forState:UIControlStateSelected];
    [self.deleteButton2 setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateSelected];
}

- (IBAction)deleteButtonPressed:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 1:
        {
            [self.nameTextField1 resignFirstResponder];
            self.cellTag = self.tag * 2;
            break;
        }
        case 2:
        {
            [self.nameTextField2 resignFirstResponder];
            self.cellTag = self.tag * 2 + 1;
            break;
        }
    }
    
    sender.selected = !sender.selected;
    [self performSelector:@selector(deleteCell) withObject:nil afterDelay:0.01];
}

- (void)deleteCell
{
    if ([delegate respondsToSelector:@selector(deleteHousingDesk:)])
    {
        [delegate deleteHousingDesk:self];
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
    NSString *hourseNameStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //截取字符串
    NSString *tempString = [NSString cutString:hourseNameStr withMaxLengthOfStr:kHousingDeskNameLength];
    textField.text = tempString;
    
    switch (textField.tag)
    {
        case 1:
        {
            self.cellTag = self.tag * 2;
            break;
        }
        case 2:
        {
            self.cellTag = self.tag * 2 + 1;
            break;
        }
    }
    //cell修改的内容
    if ([delegate respondsToSelector:@selector(housingDeskContentChange:withNewName:)])
    {
        [delegate housingDeskContentChange:self withNewName:tempString];
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
    if (range.location >= kHousingDeskNameLength)
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
