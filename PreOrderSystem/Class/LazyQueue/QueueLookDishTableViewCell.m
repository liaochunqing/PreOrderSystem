//
//  QueueLookDishTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import "QueueLookDishTableViewCell.h"
#import "QueueArrangDataClass.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"
#import "OfflineManager.h"

#define kQueueLookDishCellLabelDefaultHeight 25
#define kQueueLookDishCellLabelHeightDeltas 5

@interface QueueLookDishTableViewCell ()
{
    float _nameLabelHight;
}

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *remarkLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceAndQuantityLabel;
@property (strong, nonatomic) IBOutlet UILabel *origionPriceLabel;

@end

@implementation QueueLookDishTableViewCell

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

    
    [self updateNameLabel:dishClass.name];
    [self updateRemarkLabel:dishClass.currentRemarkArray];
    
    NSString *priceAndQuantityTitle = NSLocalizedString(@"优惠价:", nil);
    NSString *origionPriceTitle = NSLocalizedString(@"原价:", nil);
    if ([dishClass.currentPriceStr isEqualToString:dishClass.originalPriceStr])//无优惠价
    {
        priceAndQuantityTitle = @"";
        self.origionPriceLabel.hidden = YES;
        CGRect remarkLabelRect = self.remarkLabel.frame;
        remarkLabelRect.origin.y = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height;
        self.remarkLabel.frame = remarkLabelRect;
    }
    else
    {
        self.origionPriceLabel.hidden = NO;
        CGRect origionPriceLabelFram = self.origionPriceLabel.frame;
        origionPriceLabelFram.origin.y = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height;
        self.origionPriceLabel.frame = origionPriceLabelFram;
        self.origionPriceLabel.text = [NSString stringWithFormat:@"%@ %@%@",origionPriceTitle, [[OfflineManager sharedOfflineManager] getCurrencySymbol], dishClass.originalPriceStr];
        CGRect remarkRect = self.remarkLabel.frame;
        remarkRect.origin.y = self.origionPriceLabel.frame.origin.y + self.origionPriceLabel.frame.size.height;
        self.remarkLabel.frame = remarkRect;
    }
    self.priceAndQuantityLabel.text = [NSString stringWithFormat:@"%@ %@%@ x %d",priceAndQuantityTitle, [[OfflineManager sharedOfflineManager] getCurrencySymbol], dishClass.currentPriceStr, dishClass.quantity];
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
    self.nameLabel.text = [NSString stringWithFormat:@"%d.%@", (int)(self.tag + 1), dishName];
    nameHeight = [self.nameLabel adjustLabelHeight] + kQueueLookDishCellLabelHeightDeltas;
    if (nameHeight < kQueueLookDishCellLabelDefaultHeight)
    {
        nameHeight = kQueueLookDishCellLabelDefaultHeight;
    }
    
    _nameLabelHight = nameHeight;
    
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
        remarkFrame.origin.y += _nameLabelHight - kQueueLookDishCellLabelDefaultHeight;
        self.remarkLabel.frame = remarkFrame;
    }
    else
    {
        [self.remarkLabel removeFromSuperview];
        self.remarkLabel = nil;
    }
}

- (CGFloat)getQueueLookDishTableViewCellHeight:(QueueArrangDishDataClass *)dishClass
{
    CGFloat cellHeight = 0;
    [self updateNameLabel:dishClass.name];
    [self updateRemarkLabel:dishClass.currentRemarkArray];
    float origionPriceOffSet = 0.0;
    if (![dishClass.originalPriceStr isEqualToString:dishClass.currentPriceStr])
    {
        origionPriceOffSet = self.origionPriceLabel.frame.size.height;
    }

    cellHeight = self.nameLabel.frame.size.height + self.remarkLabel.frame.size.height + origionPriceOffSet;
    return cellHeight;
}

@end
