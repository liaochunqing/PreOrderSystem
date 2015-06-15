//
//  AddMoreHousingTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "AddMoreHousingTableViewCell.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableCommon.h"
#import "NsstringAddOn.h"

@interface AddMoreHousingTableViewCell ()
{
    BOOL isAddFlag;
}

- (IBAction)deleteButtonClicked:(UIButton *)sender;

@end

@implementation AddMoreHousingTableViewCell

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
    
}

- (void)refreshCellAfterGetData:(NSString *)areaName
{
    self.backgroundColor = [UIColor clearColor];
    self.housingTextField.text = areaName;
    [self addPictureToView];
}

- (IBAction)deleteButtonClicked:(UIButton *)sender
{
    [self.housingTextField resignFirstResponder];
    [self performSelector:@selector(deleteCell) withObject:nil afterDelay:0.3];
}

- (void)deleteCell
{
    if ([self.delegate respondsToSelector:@selector(deleteHousing:)])
    {
        [self.delegate deleteHousing:self];
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
    NSString *tempStr = [self.housingTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *lastAreaStr = [NSString cutString:tempStr withMaxLengthOfStr:kDtHousingNameMaxLen];
    if ([self.delegate respondsToSelector:@selector(housingNameChange:withNewHousingName:)])
    {
        [self.delegate housingNameChange:self withNewHousingName:lastAreaStr];
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
