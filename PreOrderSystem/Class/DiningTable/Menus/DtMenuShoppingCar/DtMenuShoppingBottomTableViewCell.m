//
//  DtMenuShoppingBottomTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-1-3.
//
//
#import "Constants.h"
#import "DtMenuShoppingBottomTableViewCell.h"

#define kTitleFirstColor [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0]
#define kTitleSecondColor [UIColor colorWithRed:116.0/255.0 green:159.0/255.0 blue:0.0 alpha:1.0]

@interface DtMenuShoppingBottomTableViewCell ()
{
    UIButton *addRemarkButton;
}

@end

@implementation DtMenuShoppingBottomTableViewCell

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===DtMenuShoppingBottomTableViewCell,dealloc===");
#endif
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        addRemarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addRemarkButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
        addRemarkButton.frame = CGRectMake(0, 5, 170, 44);
        [addRemarkButton addTarget:self action:@selector(addRemarkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:addRemarkButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDtMenuShoppingBottomCell
{
    self.backgroundColor = [UIColor clearColor];
    if (!kSystemVersionIsIOS7) {
        //取消ios6 group样式边框
        UIView *tempView = [[UIView alloc] init] ;
        [self setBackgroundView:tempView];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    [addRemarkButton setTitle:kLoc(@"click_to_add_remark") forState:UIControlStateNormal];
    [self whetherAddBtnEnable];
}

- (void)whetherAddBtnEnable
{
    if (self.remarkQuantity < self.dishQuantity)
    {
        addRemarkButton.enabled = YES;
        [addRemarkButton setTitleColor:kTitleSecondColor forState:UIControlStateNormal];
    }
    else
    {
        addRemarkButton.enabled = NO;
        [addRemarkButton setTitleColor:kTitleFirstColor forState:UIControlStateNormal];
    }
}

- (void)addRemarkBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dtMenuShoppingBottomTableViewCell:)])
    {
        [self.delegate dtMenuShoppingBottomTableViewCell:self];
    }
}

@end
