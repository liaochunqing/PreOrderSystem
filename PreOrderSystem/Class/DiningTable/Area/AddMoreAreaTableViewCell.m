//
//  AddMoreAreaTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "AddMoreAreaTableViewCell.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableCommon.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"

@interface AddMoreAreaTableViewCell ()
{
    BOOL isAddFlag;
}

- (IBAction)deleteButtonClicked:(UIButton *)sender;

@end

@implementation AddMoreAreaTableViewCell

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

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (void)refreshCellAfterGetData:(NSString *)areaName
{
    self.backgroundColor = [UIColor clearColor];
    self.areaTextField.text = areaName;
    [self addPictureToView];
}

- (IBAction)deleteButtonClicked:(UIButton *)sender
{
    [self.areaTextField resignFirstResponder];
    [self performSelector:@selector(deleteCell) withObject:nil afterDelay:0.3];
}

- (void)deleteCell
{
    if ([self.delegate respondsToSelector:@selector(deleteArea:)])
    {
        [self.delegate deleteArea:self];
    }
}

- (void)addPictureToView
{
    self.lineImageView.image = [UIImage imageFromMainBundleFile:@"dt_addLine.png"];
    [self.deleteButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dt_deleteButton.png"] forState:UIControlStateNormal];
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(keyboardShow:)])
    {
        [self.delegate keyboardShow:self];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSString *tempStr = [self.areaTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *lastAreaStr = [NSString cutString:tempStr withMaxLengthOfStr:kDtAreaNameMaxLen];
    if ([self.delegate respondsToSelector:@selector(areaNameChange:withNewAreaName:)])
    {
        [self.delegate areaNameChange:self withNewAreaName:lastAreaStr];
    }
    if ([self.delegate respondsToSelector:@selector(keyboardHide:)])
    {
        [self.delegate keyboardHide:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
