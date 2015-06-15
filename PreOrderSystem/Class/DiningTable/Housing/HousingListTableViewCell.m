//
//  HousingListTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "HousingListTableViewCell.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableCommon.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"

@interface HousingListTableViewCell ()

- (IBAction)deleteButtonClicked:(UIButton *)sender;

@end

@implementation HousingListTableViewCell

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

- (void)refreshCellAfterGetData:(NSString *)housingName
{
    self.backgroundColor = [UIColor clearColor];
    self.housingTextField.text = housingName;
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
    [self.deleteButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dt_deleteButton.png"] forState:UIControlStateNormal];
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //截取字符串
    NSString *tempStr = [self.housingTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
    if ([NSString strIsOverMaxLen:tempStr withMaxLen:kDtHousingNameMaxLen])
    {
        [PSAlertView showWithMessage:kLoc(@"housing_name_has_reached_max")];
    }
    NSString *lastAreaStr = [NSString cutString:tempStr withMaxLengthOfStr:kDtHousingNameMaxLen];
    if ([self.delegate respondsToSelector:@selector(housingNameChange:withNewHousingName:)])
    {
        [self.delegate housingNameChange:self withNewHousingName:lastAreaStr];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
