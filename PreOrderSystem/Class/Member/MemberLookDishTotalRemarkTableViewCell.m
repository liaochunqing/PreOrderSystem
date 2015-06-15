//
//  MemberLookDishTotalRemarkTotalRemarkTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import "MemberLookDishTotalRemarkTableViewCell.h"
#import "MemberSuperDataClass.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"

#define kMemberLookDishTotalRemarkCellDefaultHeight 40
#define kMemberLookDishTotalRemarkCellLabelDefaultHeight 21
#define kMemberLookDishTotalRemarkCellLabelHeightDeltas 5

@interface MemberLookDishTotalRemarkTableViewCell ()
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *remarkLabel;

@end

@implementation MemberLookDishTotalRemarkTableViewCell

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

- (void)updateMemberLookDishTotalRemarkCell:(NSString *)totalRemark
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
        remarkHeight = [self.remarkLabel adjustLabelHeight] + kMemberLookDishTotalRemarkCellLabelHeightDeltas;
        if (remarkHeight < kMemberLookDishTotalRemarkCellLabelDefaultHeight)
        {
            remarkHeight = kMemberLookDishTotalRemarkCellLabelDefaultHeight;
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

- (CGFloat)getMemberLookDishTotalRemarkTableViewCellHeight:(NSString *)finalRemark
{
    const CGFloat spaceY = 10;
    CGFloat cellHeight = 0;
    [self updateRemarkLabel:finalRemark];
    cellHeight = spaceY + self.remarkLabel.frame.size.height + spaceY;
    if (cellHeight < kMemberLookDishTotalRemarkCellDefaultHeight)
    {
        cellHeight = kMemberLookDishTotalRemarkCellDefaultHeight;
    }
    return cellHeight;
}

@end
