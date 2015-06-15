//
//  QueueLookDishTotalPriceTotalPriceTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import "DtPreOrderDishTotalPriceTableViewCell.h"
#import "QueueArrangDataClass.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"
#import "DetailTextView.h"
#import "OfflineManager.h"

#define kDtPreOrderDishTotalPriceTableViewCellDefaultHeight 40
#define kQueueLookDishTotalPriceCellLabelDefaultHeight 21
#define kQueueLookDishTotalPriceCellLabelHeightDeltas 5

@interface DtPreOrderDishTotalPriceTableViewCell ()
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *remarkLabel;
@property (nonatomic, weak) IBOutlet DetailTextView *totalPriceLabel;

@end

@implementation DtPreOrderDishTotalPriceTableViewCell

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

- (void)updateQueueLookDishTotalPriceCell:(CGFloat)totalPrice withFinalRemark:(NSString *)finalRemark;
{
    self.backgroundColor = [UIColor clearColor];
    self.remarkLabel.textColor = [UIColor grayColor];
    
    [self updateRemarkLabel:finalRemark];
    
    NSString *titleStr = kLoc(@"total_price");
    NSString *priceStr = [NSString stringWithFormat:@"%.2f",totalPrice];
    NSString *totalPirceStr = [NSString stringWithFormat:@"%@  %@ %@", titleStr, [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:[priceStr floatValue]]];
    [self.totalPriceLabel setText:totalPirceStr WithFont:self.totalPriceLabel.font AndColor:[UIColor orangeColor]];
    [self.totalPriceLabel setKeyWordTextArray:[NSArray arrayWithObjects:titleStr, nil] WithFont:self.totalPriceLabel.font AndColor:[UIColor blackColor]];
}

- (void)updateRemarkLabel:(NSString *)dishRemark
{
    CGFloat remarkHeight = 0;
    if (![NSString strIsEmpty:dishRemark])
    {
        self.remarkLabel.text = [NSString stringWithFormat:@"%@ : %@", kLoc(@"remark"), dishRemark];
        remarkHeight = [self.remarkLabel adjustLabelHeight] + kQueueLookDishTotalPriceCellLabelHeightDeltas;
        if (remarkHeight < kQueueLookDishTotalPriceCellLabelDefaultHeight)
        {
            remarkHeight = kQueueLookDishTotalPriceCellLabelDefaultHeight;
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

- (CGFloat)getDtPreOrderDishTotalPriceTableViewCellHeight:(NSString *)finalRemark
{
    const CGFloat spaceY = 10;
    CGFloat cellHeight = 0;
    [self updateRemarkLabel:finalRemark];
    cellHeight = spaceY + self.remarkLabel.frame.size.height + spaceY;
    if (cellHeight < kDtPreOrderDishTotalPriceTableViewCellDefaultHeight)
    {
        cellHeight = kDtPreOrderDishTotalPriceTableViewCellDefaultHeight;
    }
    return cellHeight;
}

@end
