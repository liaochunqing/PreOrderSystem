//
//  ArrangTableViewCell.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-7.
//
//

#import "ArrangTableViewCell.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "Constants.h"
#import "QueueCommon.h"


#define kHandleArrang1BtnTag 1000
#define kHandleArrang2BtnTag 1100
#define kHandleArrang3BtnTag 1200
#define kHandleArrang4BtnTag 1300
#define kHandleArrang5BtnTag 1400

/*其他ArrangTableViewCell中的Arrang已经有被点击的了*/
#define kOtherArrangHasSelected @"otherArrangHasSelected"
#define kCellTagKey @"cellTagKey"
#define kSelectIndexKey @"selectIndexKey"
#define kSuperCellTagKey @"superCellTagKey"

#define kSelectArrangBgImage [UIImage imageFromMainBundleFile:@"queue_selectedArrangBg.png"]
#define kLightGrayColor [UIColor colorWithRed:150.0/255.0 green:151.0/255.0 blue:153.0/255.0 alpha:1.0]
#define kDarkGrayColor [UIColor colorWithRed:114.0/255.0 green:117.0/255.0 blue:124.0/255.0 alpha:1.0]

@implementation ArrangTableViewCell

@synthesize delegate;
@synthesize serialNumber1Label;
@synthesize peopleNumber1Label;
@synthesize serialNumber2Label;
@synthesize peopleNumber2Label;
@synthesize serialNumber3Label;
@synthesize peopleNumber3Label;
@synthesize serialNumber4Label;
@synthesize peopleNumber4Label;
@synthesize serialNumber5Label;
@synthesize peopleNumber5Label;
@synthesize handleArrang1Button;
@synthesize handleArrang2Button;
@synthesize handleArrang3Button;
@synthesize handleArrang4Button;
@synthesize handleArrang5Button;
@synthesize selectArrang1BgView;
@synthesize selectArrang2BgView;
@synthesize selectArrang3BgView;
@synthesize selectArrang4BgView;
@synthesize selectArrang5BgView;
@synthesize lineImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//更改排号状态
- (IBAction)handleArrangButongPressed:(UIButton *)sender
{
    int tempIndex = 0;
    switch (sender.tag)
    {
        case kHandleArrang1BtnTag:
        {
            tempIndex = 0;
            break;
        }
        case kHandleArrang2BtnTag:
        {
            tempIndex = 1;
            break;
        }
        case kHandleArrang3BtnTag:
        {
            tempIndex = 2;
            break;
        }
        case kHandleArrang4BtnTag:
        {
            tempIndex = 3;
            break;
        }
        case kHandleArrang5BtnTag:
        {
            tempIndex = 4;
            break;
        }
        default:
            return;
    }
    // 点击不选择其他的排号
//    [self postNotification:tempIndex];
    
    int selectIndex = self.tag * kArrangNumberForPerCell + tempIndex;
    if ([delegate respondsToSelector:@selector(handleArrang:)])
    {
        [delegate handleArrang:selectIndex];
    }
}

- (void)addObjectToArray
{
    serialNumLabelArray = [[NSMutableArray alloc]initWithCapacity:3];
    peopleNumLabelArray = [[NSMutableArray alloc]initWithCapacity:3];
    handleArrangBtnArray = [[NSMutableArray alloc]initWithCapacity:3];
    selectArrangBgViewArray = [[NSMutableArray alloc]initWithCapacity:3];
    dishLogoArray = [[NSMutableArray alloc]initWithCapacity:3];
    
    [serialNumLabelArray addObject:self.serialNumber1Label];
    [serialNumLabelArray addObject:self.serialNumber2Label];
    [serialNumLabelArray addObject:self.serialNumber3Label];
    [serialNumLabelArray addObject:self.serialNumber4Label];
    [serialNumLabelArray addObject:self.serialNumber5Label];
    
    [peopleNumLabelArray addObject:self.peopleNumber1Label];
    [peopleNumLabelArray addObject:self.peopleNumber2Label];
    [peopleNumLabelArray addObject:self.peopleNumber3Label];
    [peopleNumLabelArray addObject:self.peopleNumber4Label];
    [peopleNumLabelArray addObject:self.peopleNumber5Label];
    
    [handleArrangBtnArray addObject:self.handleArrang1Button];
    [handleArrangBtnArray addObject:self.handleArrang2Button];
    [handleArrangBtnArray addObject:self.handleArrang3Button];
    [handleArrangBtnArray addObject:self.handleArrang4Button];
    [handleArrangBtnArray addObject:self.handleArrang5Button];
    
    [selectArrangBgViewArray addObject:self.selectArrang1BgView];
    [selectArrangBgViewArray addObject:self.selectArrang2BgView];
    [selectArrangBgViewArray addObject:self.selectArrang3BgView];
    [selectArrangBgViewArray addObject:self.selectArrang4BgView];
    [selectArrangBgViewArray addObject:self.selectArrang5BgView];
    
    [dishLogoArray addObject:self.dishLogo1View];
    [dishLogoArray addObject:self.dishLogo2View];
    [dishLogoArray addObject:self.dishLogo3View];
    [dishLogoArray addObject:self.dishLogo4View];
    [dishLogoArray addObject:self.dishLogo5View];
}

- (void)updateViewAfterGetData:(NSArray *)arrangListArray withLineFlag:(BOOL)hideFlag
{
    //更新数据
    int arrangCount = [arrangListArray count];
    if (0 < arrangCount) {
        [self addNotification];
        [self addObjectToArray];
        
        int startIndex = self.tag * kArrangNumberForPerCell;
        int endIndex = startIndex + kArrangNumberForPerCell;
        int serialLabelCount = [serialNumLabelArray count];
        
        int highlightedIndex = -1;
        for (int i = 0; i < arrangListArray.count; i++) {
            NSDictionary *item = [arrangListArray objectAtIndex:i];
            if ([[item objectForKey:@"statusValue"] intValue] == 0) {
                highlightedIndex = i;
                break;
            }
        }
        
        for (int i = startIndex; i < arrangCount && i < endIndex; i++) {
            NSMutableDictionary *arrangListDict = [[NSMutableDictionary alloc]initWithDictionary:[arrangListArray objectAtIndex:i]];
            
            int labelIndex = i % kArrangNumberForPerCell;
            if (labelIndex < serialLabelCount) {
                ((UILabel *)[serialNumLabelArray objectAtIndex:labelIndex]).text = [NSString stringWithFormat:@"%@%@", [arrangListDict objectForKey:@"serialNumber"],kLoc(@"number")];
                ((UILabel *)[peopleNumLabelArray objectAtIndex:labelIndex]).text = [NSString stringWithFormat:@"%@%@",[arrangListDict objectForKey:@"peopleNumber"],kLoc(@"person")];
                ((UIButton *)[handleArrangBtnArray objectAtIndex:labelIndex]).hidden = NO;
                
                NSArray *dishArray = [arrangListDict objectForKey:@"dishes"];
                if ([dishArray count]) {
                    ((UIImageView *)[dishLogoArray objectAtIndex:labelIndex]).image = LoadImageWithPNGType(@"queue_dishLogo");
                } else {
                    ((UIImageView *)[dishLogoArray objectAtIndex:labelIndex]).image = nil;
                }
            }
        }
        if (highlightedIndex != -1 && (highlightedIndex / kArrangNumberForPerCell) == self.tag) {
            int selfHighlightIndex = highlightedIndex % kArrangNumberForPerCell + 1;
            
            NSString *bgViewName = [NSString stringWithFormat:@"selectArrang%dBgView", selfHighlightIndex];
            NSString *noLabelName = [NSString stringWithFormat:@"serialNumber%dLabel", selfHighlightIndex];
            NSString *ppLabelName = [NSString stringWithFormat:@"peopleNumber%dLabel", selfHighlightIndex];
            UIImageView *bgImageView = (UIImageView *)[self valueForKey:bgViewName];
            if (bgImageView != nil && [bgImageView isKindOfClass:[UIImageView class]]) {
                bgImageView.hidden = NO;
                bgImageView.image = kSelectArrangBgImage;
            }
            
            UILabel *serialNumberLabel = (UILabel *)[self valueForKey:noLabelName];
            if (serialNumberLabel != nil && [serialNumberLabel isKindOfClass:[UILabel class]]) {
                serialNumberLabel.textColor = [UIColor whiteColor];
            }
            
            UILabel *peopleNumberLabel = (UILabel *)[self valueForKey:ppLabelName];
            if (peopleNumberLabel != nil && [peopleNumberLabel isKindOfClass:[UILabel class]]) {
                peopleNumberLabel.textColor = [UIColor whiteColor];
            }
        }
        self.lineImageView.hidden = hideFlag;
    }
}

- (void)modifyLabelTextColor:(int)index
{
    int serialLaelCount = [serialNumLabelArray count];
    for (int i = 0; i< serialLaelCount; i++)
    {
        UIColor *serialLabelColor = nil;
        UIColor *peopleLabelColor = nil;
        if (index == i)
        {
            serialLabelColor = peopleLabelColor = [UIColor whiteColor];
        }
        else
        {
            serialLabelColor = kDarkGrayColor;
            peopleLabelColor = kLightGrayColor;
        }
        ((UILabel *)[serialNumLabelArray objectAtIndex:i]).textColor = serialLabelColor;
        ((UILabel *)[peopleNumLabelArray objectAtIndex:i]).textColor = peopleLabelColor;
    }
}

- (void)whetherShowBgView:(int)index
{
    int bgViewCount = [selectArrangBgViewArray count];
    for (int i = 0; i< bgViewCount; i++)
    {
        UIImageView *tempView = (UIImageView *)[selectArrangBgViewArray objectAtIndex:i];
        tempView.hidden = (index == i)?NO:YES;
        tempView.image = (tempView.hidden)?nil:kSelectArrangBgImage;
    }
}

#pragma mark Notification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotify:) name:kOtherArrangHasSelected object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)postNotification:(int)index
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[NSNumber numberWithInt:self.tag] forKey:kCellTagKey];
    [dict setObject:[NSNumber numberWithInt:index] forKey:kSelectIndexKey];
    [dict setObject:[NSNumber numberWithInt:self.superCellTag] forKey:kSuperCellTagKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOtherArrangHasSelected object:nil userInfo:dict];
}

- (void)handleNotify:(NSNotification*)notify
{
    int superCellTag = [[notify.userInfo objectForKey:kSuperCellTagKey] intValue];
    if (superCellTag == self.superCellTag)
    {
        int cellTag = [[notify.userInfo objectForKey:kCellTagKey] intValue];
        int index = [[notify.userInfo objectForKey:kSelectIndexKey] intValue];
        if (cellTag != self.tag)
        {
            index = -1;
        }
        [self modifyLabelTextColor:index];
        [self whetherShowBgView:index];
    }
}

#pragma mark dealloc

- (void)dealloc
{
    [self removeNotification];
}

@end
