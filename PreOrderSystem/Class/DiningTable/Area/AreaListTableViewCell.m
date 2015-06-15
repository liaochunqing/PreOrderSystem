//
//  AreaListTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "AreaListTableViewCell.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableCommon.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"

@interface AreaListTableViewCell ()

- (IBAction)deleteButtonClicked:(UIButton *)sender;
- (IBAction)addHousingBtnClicked:(UIButton *)sender;

@end

@implementation AreaListTableViewCell

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

- (void)refreshCellAfterGetData:(NSString *)areaName
{
    self.backgroundColor = [UIColor clearColor];
    self.areaTextField.text = areaName;
    [self addPictureToView];
}

- (IBAction)addHousingBtnClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(gotoHousingListView:)])
    {
        [self.delegate gotoHousingListView:self];
    }
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
    [self.deleteButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dt_deleteButton.png"] forState:UIControlStateNormal];
    [self.addHousingButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dt_addHousingNormal.png"] forState:UIControlStateNormal];
    [self.addHousingButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dt_addHousingHighlight.png"] forState:UIControlStateHighlighted];
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //截取字符串
    NSString *tempStr = [self.areaTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([NSString strIsOverMaxLen:tempStr withMaxLen:kDtAreaNameMaxLen])
    {
        [PSAlertView showWithMessage:kLoc(@"area_name_has_reached_max")];
    }
    NSString *lastAreaStr = [NSString cutString:tempStr withMaxLengthOfStr:kDtAreaNameMaxLen];
    if ([self.delegate respondsToSelector:@selector(areaNameChange:withNewAreaName:)])
    {
        [self.delegate areaNameChange:self withNewAreaName:lastAreaStr];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
