//
//  TakeOutNoticeCell.m
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-10-14.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "TakeOutNoticeCell.h"
#import "UIImage+imageWithContentsOfFile.h"

@interface TakeOutNoticeCell ()
{
    
}

- (IBAction)deleteBtnClicked:(id)sender;

@end


@implementation TakeOutNoticeCell

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

- (IBAction)deleteBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(deleteTakeOutNoticeCell:)])
    {
        [self.delegate deleteTakeOutNoticeCell:self.tag];
    }
}

- (void)reloadDataAfterLoadView:(NSString *)noticeStr
{
    [self addPictureToView];
    self.serialNumberLabel.text = [NSString stringWithFormat:@"%d、",self.tag + 1];
    self.noticeTextField.text = noticeStr;
}

- (void)addPictureToView
{
    self.noticeBgView.image = [UIImage imageFromMainBundleFile:@"rule_noticeBg.png"];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(beginEditingTakeOutNoticeCell:)])
    {
        [self.delegate beginEditingTakeOutNoticeCell:self];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(endEditingTakeOutNoticeCell:)])
    {
        [self.delegate endEditingTakeOutNoticeCell:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
