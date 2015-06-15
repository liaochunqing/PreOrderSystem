//
//  QueueLookDishTotalRemarkTotalRemarkTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import "QueueLookDishTotalRemarkTableViewCell.h"
#import "QueueArrangDataClass.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"

#define kQueueLookDishTotalRemarkCellDefaultHeight 40
#define kQueueLookDishTotalRemarkCellLabelDefaultHeight 21
#define kQueueLookDishTotalRemarkCellLabelHeightDeltas 5

@interface QueueLookDishTotalRemarkTableViewCell ()
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *remarkLabel;

@end

@implementation QueueLookDishTotalRemarkTableViewCell

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

- (void)updateQueueLookDishTotalRemarkCell:(NSString *)totalRemark
{
    self.backgroundColor = [UIColor clearColor];

    [self updateRemarkLabel:totalRemark];
}

- (void)updateRemarkLabel:(NSString *)dishRemark
{
    CGFloat remarkHeight = 0;
    if (![NSString strIsEmpty:dishRemark])
    {
        self.remarkLabel.text = [NSString stringWithFormat:@"%@ : %@", kLoc(@"remark"), dishRemark];
        remarkHeight = [self.remarkLabel adjustLabelHeight] + kQueueLookDishTotalRemarkCellLabelHeightDeltas;
        if (remarkHeight < kQueueLookDishTotalRemarkCellLabelDefaultHeight)
        {
            remarkHeight = kQueueLookDishTotalRemarkCellLabelDefaultHeight;
        }
        CGRect remarkFrame = self.remarkLabel.frame;
        remarkFrame.size.height = remarkHeight;
        self.remarkLabel.frame = remarkFrame;
    }
    else
    {
        [self.remarkLabel removeFromSuperview];
        self.remarkLabel = nil;
    }
}

- (CGFloat)getQueueLookDishTotalRemarkTableViewCellHeight:(NSString *)finalRemark
{
    const CGFloat spaceY = 10;
    CGFloat cellHeight = 0;
    [self updateRemarkLabel:finalRemark];
    cellHeight = spaceY + self.remarkLabel.frame.size.height + spaceY;
    if (cellHeight < kQueueLookDishTotalRemarkCellDefaultHeight)
    {
        cellHeight = kQueueLookDishTotalRemarkCellDefaultHeight;
    }
    return cellHeight;
}

@end
