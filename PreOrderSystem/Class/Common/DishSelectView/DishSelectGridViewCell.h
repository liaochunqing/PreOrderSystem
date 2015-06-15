//
//  DishSelectGridViewCell.h
//  PreOrderSystem
//
//  Created by mac on 14-7-5.
//
//

#import "UIGridViewCell.h"

@interface DishSelectGridViewCell : UIGridViewCell

//背景图片
@property (strong, nonatomic) IBOutlet UIImageView *backgroungImgView;


//菜名
@property (strong, nonatomic) IBOutlet UILabel *cookbookNameLabel;


//价格
@property (strong, nonatomic) IBOutlet UILabel *cookbookPriceLabel;

//选中图标.
@property (strong, nonatomic) IBOutlet UIImageView *selectedImv;

//显示该菜被点了多少份
@property (strong, nonatomic) IBOutlet UIButton *dishCountBtn;

//设置字体颜色
- (void)setWordColor:(UIColor *)wordColor;

//沽清图标
@property (strong, nonatomic) IBOutlet UIImageView *soldOutImv;

//菜品暂停供应图
@property (strong, nonatomic) IBOutlet UIImageView *stopImv;


/**
 *  设置是否显示沽清图片
 *  isShow:显示or隐藏
 */
- (void)setShowSoldOutImv:(BOOL)isShow;


/**
 *  设置是否显示暂停菜品图标
 *
 *  @param isShow 显示or隐藏
 */
- (void)setStopSupplyImv:(BOOL)isShow;



@end
