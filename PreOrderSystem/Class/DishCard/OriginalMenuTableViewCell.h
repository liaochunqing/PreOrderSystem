//
//  OriginalMenuTableViewCell.h
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import <UIKit/UIKit.h>
@class OriginalMenuTableViewCell;
@protocol originalMenueTableViewCellDelegate <NSObject>

@optional

/**
 *  点击了该行的选择按钮
 *
 *  @param cell self
 *  @param btn  _selectedBtn
 */
- (void)tableViewCell:(OriginalMenuTableViewCell *)cell didPressBtn:(UIButton *)btn;

@end

@interface OriginalMenuTableViewCell : UITableViewCell

@property (nonatomic, weak) id<originalMenueTableViewCellDelegate> delegate;

//菜名
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

//未选中
@property (strong, nonatomic) IBOutlet UIImageView *unSelectImageVIew;

//已选
@property (strong, nonatomic) IBOutlet UIImageView *selectedImageView;

//选择按钮
@property (strong, nonatomic) IBOutlet UIButton *selectedBtn;

//是否已被选中
@property (nonatomic, assign) BOOL isSelected;

/**
 *  设置选中图片是否显示.
 *
 *  @param selected 是否选中该项
 */
-(void)isSelected:(BOOL)selected;

/**
 *  点击了选择按钮
 *
 *  @param sender btn
 */
- (IBAction)didPressSelectedBtn:(id)sender;

@end
