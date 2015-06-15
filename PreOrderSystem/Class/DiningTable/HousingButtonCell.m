//
//  HousingButtonCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-24.
//
//

#import "HousingButtonCell.h"
#import "DiningTableDataClass.h"
#import "NsstringAddOn.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableImageName.h"

#define kHousingNameLen 20

@interface HousingButtonCell ()
{
    HousingDataClass *dataClass;
    BOOL isStatusSetting;//真正进行状态设置
    BOOL isSurface;//是否浮起
    kHousingSwitchStateType currentSwitchType;
}

- (IBAction)bigBtnClicked:(id)sender;

@end

@implementation HousingButtonCell

- (id)initWithHousingData:(NSDictionary *)dict
{
    self = [[[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@",self.class] owner:self options:nil]lastObject];
    if (self)
    {
        isStatusSetting = NO;
        isSurface = YES;
        currentSwitchType = kHousingUnKnownSwitchState;
        [self updateCellWithData:dict];
    }
    return self;
}

- (void)updateCellWithData:(NSDictionary *)housingDict
{
    if (housingDict)
    {
        dataClass = [[HousingDataClass alloc] initWithHousingData:housingDict];
        NSString *housingName = [NSString cutString:dataClass.housingName withMaxLengthOfStr:kHousingNameLen];
        self.housingNameLabel.text = housingName;
        [self addPictureToView];
    }
}

- (void)addPictureToView
{
    NSString *bgFirstImgName = kFirstStateBgImageName;
    NSString *bgSecondImgName = kSecondStateBgImageName;
    NSString *bgImgName = nil;
    NSString *stateImgName = nil;
    NSString *dishImgName = nil;
    switch (dataClass.housingStatus)
    {
        case kHousingNotOpen:
        {
            bgImgName = bgFirstImgName;
            break;
        }
        case kHousingHavedStop:
        {
            bgImgName = bgFirstImgName;
            stateImgName = kHousingFirstStateImageName;
            break;
        }
        case kHousingHavedOrder:
        {
            bgImgName = bgFirstImgName;
            stateImgName = kHousingSecondStateImageName;
            break;
        }
        case kHousingHavedOpen:
        {
            bgImgName = bgSecondImgName;
            break;
        }
        case kHousingHavedDish:
        {
            bgImgName = bgSecondImgName;
            dishImgName = kDishLogoImageName;
            break;
        }
        default:
            return;
    }
    self.stateImageView.hidden = NO;
    self.dishLogoImageView.hidden = NO;
    self.coverImageView.hidden = YES;
    self.isCheckedImageview.hidden = dataClass.unconfirmed == 0?YES:NO;
    
    self.bgImageView.image = [UIImage imageFromMainBundleFile:bgImgName];
    self.stateImageView.image = [UIImage imageFromMainBundleFile:stateImgName];
    self.dishLogoImageView.image = [UIImage imageFromMainBundleFile:dishImgName];
    self.coverImageView.image = nil;
    
    self.isCheckedImageview.image = [UIImage imageNamed:@"order_unreadTagImageView.png"];
}

- (void)updateHousingBtnCellUI:(kHousingSwitchStateType)stateType withStatusSettingDict:(NSDictionary *)dict
{
    currentSwitchType = stateType;
    StatusSettingDataClass *statusSettingClass = [[StatusSettingDataClass alloc] initWithStatusSettingData:dict];
    switch (stateType)
    {
        case kHousingOrderSwitchState:
        {
            [self modifyPicByStatusArray:statusSettingClass.bookingArray];
            break;
        }
        case kHousingStopSwitchState:
        {
            [self modifyPicByStatusArray:statusSettingClass.disablingArray];
            break;
        }
        case kHousingClearSwitchState:
        {
            [self modifyPicByStatusArray:statusSettingClass.clearingArray];
            break;
        }
        default:
        {
            isStatusSetting = NO;
            isSurface = NO;
            [self addPictureToView];
#ifdef DEBUG
            NSLog(@"===%s====",__FUNCTION__);
#endif
            break;
        }
    }
}

- (void)modifyPicByStatusArray:(NSArray *)array
{
    isStatusSetting = YES;
    isSurface = NO;
    int tempCount = [array count];
    for (int k = 0; k < tempCount; k++)
    {
        int tempStatus = [[array objectAtIndex:k]integerValue];
        if (dataClass.housingStatus == tempStatus)
        {
            isSurface = YES;
            break;
        }
    }
    if (isSurface)
    {
        self.coverImageView.hidden = YES;
        self.coverImageView.image = nil;
        if ((kHousingHavedOpen != dataClass.housingStatus) && (kHousingHavedDish != dataClass.housingStatus))
        {
            self.bgImageView.image = [UIImage imageFromMainBundleFile:kThirdStateBgImageName];
        }
    }
    else
    {
        self.coverImageView.hidden = NO;
        self.coverImageView.image = [UIImage imageFromMainBundleFile:kHousingBtnCellCoverBgImageName];
    }
    
#ifdef DEBUG
    NSLog(@"===%s,%@====", __FUNCTION__,array);
#endif
}

- (void)updateStatePicByHousingStatus
{
    if (self.bigButton.selected)
    {
        switch (currentSwitchType)
        {
            case kHousingOrderSwitchState:
            {
                self.stateImageView.image = [UIImage imageFromMainBundleFile:kHousingSecondStateImageName];
                break;
            }
            case kHousingStopSwitchState:
            {
                self.stateImageView.image = [UIImage imageFromMainBundleFile:kHousingFirstStateImageName];
                self.bgImageView.image = [UIImage imageFromMainBundleFile:kThirdStateBgImageName];
                break;
            }
            case kHousingClearSwitchState:
            {
                self.stateImageView.hidden = YES;
                self.dishLogoImageView.hidden = YES;
                self.bgImageView.image = [UIImage imageFromMainBundleFile:kThirdStateBgImageName];
                break;
            }
            default:
            {
                break;
            }
        }
    }
    else
    {
        switch (currentSwitchType)
        {
            case kHousingOrderSwitchState:
            {
                self.stateImageView.image = nil;
                break;
            }
            case kHousingStopSwitchState:
            {
                self.stateImageView.image = nil;
                if ((kHousingHavedOpen == dataClass.housingStatus) || (kHousingHavedDish == dataClass.housingStatus))
                {
                    self.bgImageView.image = [UIImage imageFromMainBundleFile:kSecondStateBgImageName];
                }
                break;
            }
            case kHousingClearSwitchState:
            {
                self.stateImageView.hidden = NO;
                self.dishLogoImageView.hidden = NO;
                if ((kHousingHavedOpen == dataClass.housingStatus) || (kHousingHavedDish == dataClass.housingStatus))
                {
                    self.bgImageView.image = [UIImage imageFromMainBundleFile:kSecondStateBgImageName];
                }
                break;
            }
            default:
            {
                break;
            }
        }
    }
}

- (void)executeHousingBtnCellDelegateMethod
{
    if ([self.delegate respondsToSelector:@selector(housingBtnCellSelected:withHousingData:withStatusSetting:)])
    {
        [self.delegate housingBtnCellSelected:self withHousingData:dataClass withStatusSetting:isStatusSetting];
    }
}

- (IBAction)bigBtnClicked:(id)sender
{
    self.bigButton.selected = !self.bigButton.selected;
    if (isStatusSetting)
    {
        if (isSurface)
        {
            [self updateStatePicByHousingStatus];
            [self executeHousingBtnCellDelegateMethod];
        }
    }
    else
    {
        [self executeHousingBtnCellDelegateMethod];
    }
}

@end
