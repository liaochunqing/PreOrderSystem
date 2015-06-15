//
//  StaffInfoCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-7.
//
//

#import "StaffInfoCell.h"
#import "StaffManagementSuperDataClass.h"
#import "NsstringAddOn.h"
#import "LoadPicture.h"

#define kHeadImgforKeyPath @"headImg"

@interface StaffInfoCell ()
{
    StaffManagementStaffInfoDataClass *staffClass;
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *headImgFrameView;
@property (nonatomic, weak) IBOutlet UIImageView *defaultHeadImgView;
@property (nonatomic, weak) IBOutlet UILabel *nameTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *postTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *postLabel;
@property (nonatomic, weak) IBOutlet UILabel *accountTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *accountLabel;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (IBAction)editBtnClicked:(UIButton*)sender;
- (IBAction)deleteBtnClicked:(UIButton *)sender;

@end

@implementation StaffInfoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"StaffInfoCell" owner:self options:nil]lastObject];
    if (self)
    {
        [self addPictureToView];
        [self addLocalizedString];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)updateStaffInfoCell:(StaffManagementStaffInfoDataClass *)staffInfo
{
    staffClass = staffInfo;
    self.nameLabel.text = staffInfo.name;
    self.postLabel.text = staffInfo.postName;
    self.accountLabel.text = [NSString stringWithFormat:@"%@%@", staffInfo.roomNumberStr, staffInfo.numberStr];
    
    //加载头像
    NSString *picURL = staffInfo.pictureURL;
    if (![NSString strIsEmpty:picURL])
    {
        NSURL *imageURL = [NSURL URLWithString:picURL];
//        [LoadPicture loadPicFromNetword:imageURL withImageView:self.headImgFrameView];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:data];
        self.headImgFrameView.image = image;
        self.defaultHeadImgView.image = nil;
    }
    else
    {
        self.headImgFrameView.image = nil;
        self.defaultHeadImgView.image = [UIImage imageNamed:@"more_staffHeadImg"];
    }
}

- (void)addPictureToView
{
    UIImage *btnImg = [UIImage imageNamed:@"more_staffBtnBg"];
    self.bgImageView.image = [UIImage imageNamed:@"more_staffCellBg"];
    [self.editButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    [self.deleteButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    
    self.headImgFrameView.layer.masksToBounds = YES;
    self.headImgFrameView.layer.cornerRadius = 8.0;
    self.headImgFrameView.layer.borderWidth = 1.5;
    self.headImgFrameView.layer.borderColor = [[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0] CGColor];
}

- (void)addLocalizedString
{
    
//    self.nameTitleLabel.text = kLoc(@"姓名 :", nil);
//    self.postTitleLabel.text = kLoc(@"职位 :", nil);
//    self.accountTitleLabel.text = kLoc(@"帐号 :", nil);
    
    
    self.nameTitleLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"compellation")];
    self.postTitleLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"positiion")];
    self.accountTitleLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"account")];
    
    [self.editButton setTitle:kLoc(@"edit_data") forState:UIControlStateNormal];
    [self.deleteButton setTitle:kLoc(@"delete") forState:UIControlStateNormal];
}

#pragma mark - UIButton Clicked

- (IBAction)editBtnClicked:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(staffInfoCell:withEidtData:)])
    {
        [self.delegate staffInfoCell:self withEidtData:self.tag];
    }
}

- (IBAction)deleteBtnClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(staffInfoCell:withDeleteStaff:)])
    {
        [self.delegate staffInfoCell:self withDeleteStaff:staffClass.staffIdStr];
    }
}

@end
