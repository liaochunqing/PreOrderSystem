//
//  SelectTableViewCell.m
//  PreOrderSystem
//
//  Created by mac on 14-7-4.
//
//

#import "SelectTableViewCell.h"

@implementation SelectTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 180, 44)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        //菜品价格
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(190, 0, 120, 44)];
        self.priceLabel.font = [UIFont systemFontOfSize:15];
        self.priceLabel.textColor = [UIColor grayColor];
        self.priceLabel.adjustsFontSizeToFitWidth = YES;
        self.priceLabel.textAlignment = UITextAlignmentRight;
        self.priceLabel.textColor = [UIColor colorWithRed:253.0/255.0 green:94/255.0 blue:6/255.0 alpha:1];
        
        //该菜点了多少份
        self.dishCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(320, 0, 44, 44)];
        self.dishCountLabel.textAlignment = UITextAlignmentCenter;
        self.dishCountBackgroundImv = [[UIImageView alloc]initWithFrame:self.dishCountLabel.frame];
        [self.dishCountBackgroundImv setImage:[UIImage imageNamed:@"dishCount"]];
        self.dishCountBackgroundImv.hidden = YES;
        self.dishCountBackgroundImv.hidden = YES;
        
        //该菜是否被选中
        self.unSelectImageVIew = [[UIImageView alloc]initWithFrame:CGRectMake(320, 0, 44, 44)];
        self.unSelectImageVIew.image = [UIImage imageNamed:@"dishesPicker_packageNormal.png"];
        self.selectedImageView = [[UIImageView alloc]initWithFrame:self.unSelectImageVIew.frame];
        self.selectedImageView.image = [UIImage imageNamed:@"dishesPicker_packageSelected.png"];
        self.selectedImageView.hidden = YES;
        self.unSelectImageVIew.hidden = YES;

        //暂时屏蔽点菜份数:
        //[self.contentView addSubview:self.dishCountBackgroundImv];
        //[self.contentView addSubview:self.dishCountLabel];
        
        //沽清图标
        self.soldOutImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 20, 0, 63, 44)];
        self.soldOutImv.backgroundColor = [UIColor clearColor];
        [self.soldOutImv setImage:[UIImage imageNamed:@"dishCard_SoldOut.png"]];
        self.soldOutImv.hidden = YES;
        
        //暂停图标
        self.stopImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width, 0, 44, 44)];
        self.stopImv.backgroundColor = [UIColor clearColor];
        [self.stopImv setImage:[UIImage imageNamed:@"stopSupplyImv"]];
        self.stopImv.hidden = YES;
        
        //分隔线
        UIImageView *separateLineImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width + 30, 1)];
        [separateLineImv setImage:[UIImage imageNamed:@"order_dash.png"]];
        separateLineImv.contentMode = UIViewContentModeScaleToFill;
        if (self.isTaoCanSetting == NO)
        {
            [self.contentView addSubview:self.priceLabel];
        }
    
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.unSelectImageVIew];
        [self.contentView addSubview:self.selectedImageView];
        [self.contentView addSubview:separateLineImv];
        [self.contentView addSubview:self.soldOutImv];
        [self.contentView addSubview:self.stopImv];
    }
    return self;
}

- (void)resetPriceLabelWidth
{
    CGRect frame = self.priceLabel.frame;
    frame.size.width = 174.0;
    self.priceLabel.frame = frame;
    
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

-(void)isSelected:(BOOL)selected
{
    self.selectedImageView.hidden = !selected;
    self.unSelectImageVIew.hidden = NO;
}

- (void)setSelectNum:(int)selectNum
{
    if (selectNum != 0)
    {
        self.dishCountBackgroundImv.hidden = NO;
        self.dishCountLabel.hidden = NO;
        self.dishCountLabel.text = [NSString stringWithFormat:@"%d",selectNum];
    }
    else
    {
        self.dishCountLabel.hidden = YES;
        self.dishCountBackgroundImv.hidden = YES;
    }
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
