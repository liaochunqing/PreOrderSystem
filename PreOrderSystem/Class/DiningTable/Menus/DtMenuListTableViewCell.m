//
//  DtMenuListTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import "DtMenuListTableViewCell.h"
#import "DiningTableImageName.h"
#import "DtMenuDataClass.h"

#define KDefaultColBtnTag  1000
typedef enum {
    kColFirstBigBtnTag = KDefaultColBtnTag,
    kColSecondBigBtnTag,
    kColThirdBigBtnTag
}kColBigBtnTag;


//间隔时间，避免同时推出两个视图
#define kSpaceTime 1.0
static NSDate *lastClickedDate = nil;

@interface DtMenuListTableViewCell ()
{
    DtMenuCookbookDataClass *firstDataClass;
    DtMenuCookbookDataClass *secondDataClass;
    DtMenuCookbookDataClass *thirdDataClass;
}

- (IBAction)columnBtnClicked:(UIButton*)sender;

@end

@implementation DtMenuListTableViewCell

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
    lastClickedDate = nil;
#ifdef DEBUG
    NSLog(@"===DtMenuListTableViewCell,dealloc===");
#endif
}

- (void)updateCellInfo:(DtMenuCookbookDataClass *)firstClass withColumnSecond:(DtMenuCookbookDataClass *)secondClass withColumnThird:(DtMenuCookbookDataClass *)thirdClass
{
    [self addPictureToView];
    if (firstClass)
    {
        self.firstIsSoldOutImageView.hidden = firstClass.isSoldOut?NO:YES;
        self.firstIsStopImv.hidden = firstClass.isActive;
        self.colFirstBgImageview.hidden = self.colFirstBigBtn.hidden = NO;
        self.colFirstDishNameLabel.text = firstClass.name;
        firstDataClass = firstClass;
    }
    else
    {
        self.firstIsSoldOutImageView.hidden = YES;
        self.firstIsStopImv.hidden = YES;
        self.colFirstBgImageview.hidden = self.colFirstBigBtn.hidden = YES;
        self.colFirstDishNameLabel.text = @"";
        
    }
    if (secondClass)
    {
        self.secondSoldOutImageView.hidden = secondClass.isSoldOut?NO:YES;
        self.secondIsStopImv.hidden = secondClass.isActive;
        self.colSecondBgImageview.hidden = self.colSecondBigBtn.hidden = NO;
        self.colSecondDishNameLabel.text = secondClass.name;
        secondDataClass = secondClass;
    }
    else
    {
        self.secondSoldOutImageView.hidden = YES;
        self.secondIsStopImv.hidden = YES;
        self.colSecondBgImageview.hidden = self.colSecondBigBtn.hidden = YES;
        self.colSecondDishNameLabel.text = @"";
        
    }
    if (thirdClass)
    {
        self.thirdSoldOutImageView.hidden = thirdClass.isSoldOut?NO:YES;
        self.thirdIsStopImv.hidden = thirdClass.isActive;
        self.colThirdBgImageview.hidden = self.colThirdBigBtn.hidden = NO;
        self.colThirdDishNameLabel.text = thirdClass.name;
        thirdDataClass = thirdClass;
    }
    else
    {
        self.thirdSoldOutImageView.hidden = YES;
        self.thirdIsStopImv.hidden = YES;
        self.colThirdBgImageview.hidden = self.colThirdBigBtn.hidden = YES;
        self.colThirdDishNameLabel.text = @"";
        
    }
}

- (void)addPictureToView
{
    self.colFirstBgImageview.image = self.colSecondBgImageview.image = self.colThirdBgImageview.image = [UIImage imageNamed:kDtMenuListCellBgImageName];
}

-(IBAction)columnBtnClicked:(UIButton*)sender
{
    DtMenuCookbookDataClass *selectedDataClass = nil;
    switch (sender.tag)
    {
        case kColFirstBigBtnTag:
        {
            selectedDataClass = firstDataClass;
            break;
        }
        case kColSecondBigBtnTag:
        {
            selectedDataClass = secondDataClass;
            break;
        }
        case kColThirdBigBtnTag:
        {
            selectedDataClass = thirdDataClass;
            break;
        }
        default:
        {
            return;
        }
    }
    
    
    if (selectedDataClass.isSoldOut == NO && selectedDataClass.isActive &&[self.delegate respondsToSelector:@selector(dishCellSelectedAtIndex:)])
    {
        NSTimeInterval distantTime = 0;
        NSDate *currentDate = [NSDate date];
        if (nil != lastClickedDate)
        {
            distantTime = [currentDate timeIntervalSinceDate:lastClickedDate];
            lastClickedDate = currentDate;
            if (kSpaceTime > distantTime)
            {
                return;
            }
        }
        lastClickedDate = currentDate;
        
        [self.delegate dishCellSelectedAtIndex:selectedDataClass];
    }
}

@end
