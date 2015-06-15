//
//  SelectTableViewCell.h
//  PreOrderSystem
//
//  Created by mac on 14-7-4.
//
//

#import <UIKit/UIKit.h>

@interface SelectTableViewCell : UITableViewCell
//菜名
@property (strong, nonatomic) UILabel *titleLabel;

//未选中
@property (strong, nonatomic) UIImageView *unSelectImageVIew;

//已选
@property (strong, nonatomic) UIImageView *selectedImageView;

//价格
@property (nonatomic,strong) UILabel *priceLabel;

//沽清图
@property (nonatomic,strong)UIImageView *soldOutImv;

//菜品暂停供应图
@property (nonatomic,strong)UIImageView *stopImv;



//***********************************************

//在cell中只显示点菜数目(不显示勾选/取消勾选图标)

//显示这道菜点了多少份
@property (nonatomic,strong)UILabel *dishCountLabel;

//dishCountLabel的背景图.
@property (nonatomic,strong)UIImageView *dishCountBackgroundImv;

//***********************************************

// 用于套餐设置(春庆)
@property (nonatomic)BOOL isTaoCanSetting;

/**
 *  设置选中图片是否显示.
 *
 *  @param selected 是否选中该项
 */
-(void)isSelected:(BOOL)selected;

/**
 *  点菜时,若需要显示该菜点了几份,调用
 *
 *  @param selectNum 共点了几份.
 */
- (void)setSelectNum:(int)selectNum;


/**
 *  重设self.priceLabel长度(不需要显示勾选框时)
 */
- (void)resetPriceLabelWidth;

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
