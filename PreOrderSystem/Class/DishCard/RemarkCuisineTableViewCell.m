//
//  RemarkCuisineTableViewCell.m
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import "RemarkCuisineTableViewCell.h"

@implementation RemarkCuisineTableViewCell


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
}

- (void)updateViewAfterGetData:(NSString *)cuisineStr withSelected:(BOOL)flag
{
    self.backgroundColor = [UIColor clearColor];
    self.cuisineLabel.text = cuisineStr;
    
    if (flag)
    {
        self.cuisineLabel.textColor = [UIColor colorWithRed:0.313 green:0.313 blue:0.867 alpha:1.0];
    }
    else
    {
        self.cuisineLabel.textColor = [UIColor grayColor];
    }
    
    self.bgImageView.hidden = !flag;
    [self addPictureToView];
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageNamed:@"dishCard_remarkSelectedBg.png"];
}

@end
