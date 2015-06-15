//
//  DishSelectGridViewCell.m
//  PreOrderSystem
//
//  Created by mac on 14-7-5.
//
//

#import "DishSelectGridViewCell.h"

@implementation DishSelectGridViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"DishSelectGridViewCell" owner:self options:nil];
        [self addSubview:self.view];
        self.frame = self.view.frame;
        self.cookbookNameLabel.font = [UIFont boldSystemFontOfSize:18];
        self.cookbookPriceLabel.textColor = [UIColor colorWithRed:253.0/255.0 green:94/255.0 blue:6/255.0 alpha:1];
        self.cookbookPriceLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

- (void)setWordColor:(UIColor *)wordColor
{
    self.cookbookNameLabel.textColor = wordColor;
}

- (void)setShowSoldOutImv:(BOOL)isShow
{
    self.soldOutImv.hidden = isShow;
}

- (void)setStopSupplyImv:(BOOL)isShow
{
    self.stopImv.hidden = isShow;
}

@end
