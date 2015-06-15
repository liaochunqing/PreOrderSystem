//
//  DtPreOrderDishTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import "DtPreOrderDishTableViewCell.h"
#import "QueueArrangDataClass.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"
#import "OfflineManager.h"

#define kQueueLookDishCellLabelDefaultHeight 21
#define kQueueLookDishCellLabelHeightDeltas 5

@interface DtPreOrderDishTableViewCell ()
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *remarkLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceAndQuantityLabel;

@end

@implementation DtPreOrderDishTableViewCell

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

- (void)updateQueueLookDishCell:(QueueArrangDishDataClass *)dishClass
{
    self.backgroundColor = [UIColor clearColor];
    self.remarkLabel.textColor = [UIColor grayColor];
    
    self.priceAndQuantityLabel.text = [NSString stringWithFormat:@"%@%@ x %d", [[OfflineManager sharedOfflineManager] getCurrencySymbol], dishClass.currentPriceStr, dishClass.quantity];
    [self updateNameLabel:dishClass.name];
    [self updateRemarkLabel:dishClass.currentRemarkArray];
}

- (NSString *)getDishRemarkStr:(NSArray *)array
{
    NSMutableString *remarkStr = [NSMutableString string];
    for (QueueArrangDishRemarkDataClass *remarkClass in array)
    {
        NSMutableString *contentStr = [NSMutableString string];
        for (NSString *itemStr in remarkClass.contentArray)
        {
            [contentStr appendString:itemStr];
            [contentStr appendString:@";"];
        }
        [remarkStr appendString:contentStr];
    }
    return remarkStr;
}

- (void)updateNameLabel:(NSString *)dishName
{
    CGFloat nameHeight = 0;
    self.nameLabel.text = [NSString stringWithFormat:@"%d.%@", (self.tag + 1), dishName];
    nameHeight = [self.nameLabel adjustLabelHeight] + kQueueLookDishCellLabelHeightDeltas;
    if (nameHeight < kQueueLookDishCellLabelDefaultHeight)
    {
        nameHeight = kQueueLookDishCellLabelDefaultHeight;
    }
    CGRect nameFrame = self.nameLabel.frame;
    nameFrame.size.height = nameHeight;
    self.nameLabel.frame = nameFrame;
}

- (void)updateRemarkLabel:(NSArray *)remarkArray
{
    CGFloat remarkHeight = 0;
    NSString *dishRemark = [self getDishRemarkStr:remarkArray];
    if (![NSString strIsEmpty:dishRemark])
    {
        self.remarkLabel.text = [NSString stringWithFormat:@"%@ : %@", kLoc(@"note"), dishRemark];
        remarkHeight = [self.remarkLabel adjustLabelHeight] + kQueueLookDishCellLabelHeightDeltas;
        if (remarkHeight < kQueueLookDishCellLabelDefaultHeight)
        {
            remarkHeight = kQueueLookDishCellLabelDefaultHeight;
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

- (CGFloat)getDtPreOrderDishTableViewCellHeight:(QueueArrangDishDataClass *)dishClass
{
    CGFloat cellHeight = 0;
    [self updateNameLabel:dishClass.name];
    [self updateRemarkLabel:dishClass.currentRemarkArray];
    cellHeight = self.nameLabel.frame.size.height + self.remarkLabel.frame.size.height;
    return cellHeight;
}

@end
