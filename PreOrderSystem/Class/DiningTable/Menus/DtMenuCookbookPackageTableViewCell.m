//
//  DtMenuCookbookPackageTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-1-2.
//
//

#import "DtMenuCookbookPackageTableViewCell.h"
#import "DtMenuDataClass.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "PSAlertView.h"

typedef enum {
    kItemFirstBigBtnTag = 1000,
    kItemSecondBigBtnTag
}kItemBigBtnTag;

@interface DtMenuCookbookPackageTableViewCell ()
{
    NSDictionary *firstMemberDict;
    NSDictionary *secondMemberDict;
}

- (IBAction)itemBigBtnClicked:(UIButton *)sender;

@end

@implementation DtMenuCookbookPackageTableViewCell

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

- (void)updateDtMenuCookbookPackageCell:(NSDictionary *)firstItemDict withSecondItemDict:(NSDictionary *)secondItemDict
{
    self.backgroundColor = [UIColor clearColor];
    NSString *firstSelectedImgName = @"dt_menuPackageItemSelectedFirstBg.png";
    NSString *secondSelectedImgName = @"dt_menuPackageItemSelectedSecondBg.png";
    NSString *normalImgName = @"dt_menuPackageItemNormalBg.png";
    
    if (firstItemDict)
    {
        firstMemberDict = firstItemDict;
        DtMenuCookbookPackageMemberDataClass *firstMemberClass = [[DtMenuCookbookPackageMemberDataClass alloc] initWithDtMenuPackageMemberData:firstItemDict];
        self.firstNameLabel.frame = CGRectMake(54, 10, 160, 30);
        self.firstNameLabel.text = firstMemberClass.name;
        
        NSString *tempStr = @"";
        NSString *priceStr = firstMemberClass.priceStr;
        if (0 < [priceStr floatValue])
        {
            tempStr = [NSString stringWithFormat:@"(%@%@%@)", kLoc(@"plus"), priceStr, kLoc(@"yuan")];
            self.firstNameLabel.frame = CGRectMake(54, 5, 160, 30);
        }
        self.firstPriceLabel.text = tempStr;
        self.firstNormalImageView.hidden = NO;
        self.firstSelectedImageView.hidden = NO;
        if (kPackageFirstChoiceType == self.choiceType)
        {
            self.firstSelectedImageView.image = [UIImage imageFromMainBundleFile:firstSelectedImgName];
        }
        else
        {
            NSString *tempStr = nil;
            if (firstMemberClass.checked)
            {
                tempStr = secondSelectedImgName;
            }
            self.firstSelectedImageView.image = [UIImage imageFromMainBundleFile:tempStr];
        }
        self.firstNormalImageView.image = [UIImage imageFromMainBundleFile:normalImgName];
    }
    if (secondItemDict)
    {
        secondMemberDict = secondItemDict;
        DtMenuCookbookPackageMemberDataClass *secondMemberClass = [[DtMenuCookbookPackageMemberDataClass alloc] initWithDtMenuPackageMemberData:secondItemDict];
        self.secondNameLabel.frame = CGRectMake(278, 10, 160, 30);
        self.secondNameLabel.text = secondMemberClass.name;
        
        NSString *tempStr = @"";
        NSString *priceStr = secondMemberClass.priceStr;
        if (0 < [priceStr floatValue])
        {
            tempStr = [NSString stringWithFormat:@"(%@%@%@)", kLoc(@"plus"), priceStr, kLoc(@"yuan")];
            self.secondNameLabel.frame = CGRectMake(278, 5, 160, 30);
        }
        self.secondPriceLabel.text = tempStr;
        self.secondNormalImageView.hidden = NO;
        self.secondSelectedImageView.hidden = NO;
        if (kPackageFirstChoiceType == self.choiceType)
        {
            self.secondSelectedImageView.image = [UIImage imageFromMainBundleFile:firstSelectedImgName];
        }
        else
        {
            NSString *tempStr = nil;
            if (secondMemberClass.checked)
            {
                tempStr = secondSelectedImgName;
            }
            self.secondSelectedImageView.image = [UIImage imageFromMainBundleFile:tempStr];
        }
        self.secondNormalImageView.image = [UIImage imageFromMainBundleFile:normalImgName];
    }
}

- (IBAction)itemBigBtnClicked:(UIButton *)sender
{
    int indexForCell = 0;
    int checked = 0;
    int btnTag = sender.tag;
    NSMutableDictionary *tempDict = nil;
    switch (btnTag)
    {
        case kItemFirstBigBtnTag:
        {
            indexForCell = self.tag * kDtMenuPackageCellNum;
            checked = [[firstMemberDict objectForKey:kDtMenuCookbookPackageMemberCheckedKey] integerValue];
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:firstMemberDict];
            [tempDict setObject:[NSNumber numberWithInt:!checked] forKey:kDtMenuCookbookPackageMemberCheckedKey];
            
            break;
        }
        case kItemSecondBigBtnTag:
        {
            indexForCell = self.tag * kDtMenuPackageCellNum + 1;
            checked = [[secondMemberDict objectForKey:kDtMenuCookbookPackageMemberCheckedKey] integerValue];
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:secondMemberDict];
            [tempDict setObject:[NSNumber numberWithInt:!checked] forKey:kDtMenuCookbookPackageMemberCheckedKey];
            
            break;
        }
        default:
        {
#ifdef DEBUG
            NSLog(@"===%s,error===",__FUNCTION__);
#endif
            return;
        }
    }
     
    if (kPackageSecondChoiceType == self.choiceType)
    {
        if (1 != self.choiceNum)
        {
            int newSelectedNum = self.selectedTotalNum;
            if (checked)
            {
                newSelectedNum--;
            }
            else
            {
                newSelectedNum++;
            }
            if (newSelectedNum > self.choiceNum)
            {
                NSString *alertStr = [NSString stringWithFormat:@"%@%d%@",kLoc(@"select_up"),self.choiceNum,kLoc(@"item")];
                [PSAlertView showWithMessage:alertStr];
                return;
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(dtMenuCookbookPackageTableViewCell:withMemberDict:withMemberIndex:)])
    {
        [self.delegate dtMenuCookbookPackageTableViewCell:self withMemberDict:tempDict withMemberIndex:indexForCell];
    }
}

@end
