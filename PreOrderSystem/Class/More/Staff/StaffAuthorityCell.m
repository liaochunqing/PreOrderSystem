//
//  StaffAuthorityCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-8.
//
//

#import "StaffAuthorityCell.h"
#import "Constants.h"
#import "NsstringAddOn.h"


@interface StaffAuthorityCell ()
{
    BOOL isMainAuthFlag;
    BOOL isOpenAuth;
    BOOL isOpenSubAuth;
}

@property (nonatomic, weak) IBOutlet UIImageView *frameImageView;
@property (nonatomic, weak) IBOutlet UIImageView *blackFrameImgView;
@property (nonatomic, weak) IBOutlet UIImageView *hookImgView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *bigButton;

- (IBAction)bigBtnClicked:(UIButton*)sender;

@end

@implementation StaffAuthorityCell

- (id)initWithFrameType:(kStaffAuthorityCellFrameType)type withMainAuthorityFlag:(BOOL)isTrue withAuthName:(NSString *)authName withAuthOpenFlag:(BOOL)authFlag withSubAuthOpenFlag:(BOOL)subFlag
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"StaffAuthorityCell" owner:self options:nil]lastObject];
    if (self)
    {
        isMainAuthFlag = isTrue;
        isOpenAuth = authFlag;
        isOpenSubAuth = subFlag;
        
        if (isMainAuthFlag)
        {
            self.nameLabel.font = [UIFont boldSystemFontOfSize:19.0];
            self.nameLabel.textColor = [UIColor blackColor];
        }
        
        self.nameLabel.text = authName;
        [self adjustCellFrameAndPicureByType:type];
    }
    return self;
}

- (void)adjustCellFrameAndPicureByType:(kStaffAuthorityCellFrameType)type
{
    CGFloat originYDeltas = 0;
    CGFloat originXDeltas = 0;
    NSString *frameImgStr = nil;
    NSString *blackFrameImgStr = nil;
    NSString *hookImgStr = nil;
    switch (type)
    {
        case kStaffAuthorityCellSmallType:
        {
            frameImgStr = @"more_smallFrame";
            blackFrameImgStr = @"";
            hookImgStr = @"more_smallHook";
            break;
        }
        case kStaffAuthorityCellMiddleType:
        {
            frameImgStr = @"more_middleFrame";
            blackFrameImgStr = @"more_middleBlackFrame";
            hookImgStr = @"more_middleHook";
            break;
        }
        case kStaffAuthorityCellBigType:
        {
            frameImgStr = @"more_bigFrame";
            blackFrameImgStr = @"more_bigBlackFrame";
            hookImgStr = @"more_bigHook";
            originXDeltas = 2.0;
            originYDeltas = 3.0;
            
            break;
        }
        default:
        {
            return;
        }
    }
    UIImage *frameImg = LoadImageWithPNGType(frameImgStr);
    UIImage *blackFrameImg = nil;
    UIImage *hookImg = nil;
    
    if (isMainAuthFlag)
    {
        if (isOpenAuth)
        {
            hookImg = LoadImageWithPNGType(hookImgStr);
        }
        else
        {
            if (isOpenSubAuth)
            {
                blackFrameImg = LoadImageWithPNGType(blackFrameImgStr);
            }
        }
    }
    else
    {
        if (isOpenAuth)
        {
            hookImg = LoadImageWithPNGType(hookImgStr);
        }
    }
    self.frameImageView.image = frameImg;
    self.blackFrameImgView.image = blackFrameImg;
    self.hookImgView.image = hookImg;
    
    CGRect frameRect = CGRectMake(self.frameImageView.frame.origin.x, self.frameImageView.frame.origin.y, frameImg.size.width, frameImg.size.height);
    CGRect blackFrameRect = CGRectMake(self.blackFrameImgView.frame.origin.x + originXDeltas, self.blackFrameImgView.frame.origin.y + originYDeltas, blackFrameImg.size.width, blackFrameImg.size.height);
    CGRect hookRect = CGRectMake(self.hookImgView.frame.origin.x, self.hookImgView.frame.origin.y, hookImg.size.width, hookImg.size.height);
    self.frameImageView.frame = frameRect;
    self.blackFrameImgView.frame = blackFrameRect;
    self.hookImgView.frame = hookRect;
    
    /*调整cellFrame*/
    const CGFloat space = 10;
    CGFloat nameWidth = [NSString getStrWidth:self.nameLabel.text withMaxHeight:self.nameLabel.frame.size.height withFont:self.nameLabel.font withLineBreakMode:self.nameLabel.lineBreakMode];
    if (nameWidth > kNameLabelDefaultWidth)
    {
        CGRect cellFrame = self.frame;
        cellFrame.size.width = self.frame.size.width + (nameWidth - kNameLabelDefaultWidth) + space;
        self.frame = cellFrame;
    }
}

- (IBAction)bigBtnClicked:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(staffAuthorityCell:withAuthStateHavedChange:withMainAuthorityFlag:)])
    {
        [self.delegate staffAuthorityCell:self withAuthStateHavedChange:!isOpenAuth withMainAuthorityFlag:isMainAuthFlag];
    }
}

@end
