//
//  AddShortcutMenuTableViewCell.h
//  PreOrderSystem
//
//  Created by mac on 14-7-19.
//
//

#import <UIKit/UIKit.h>
@class AddShortcutMenuTableViewCell;
@protocol AddShortcutMenuTableViewCellDelegate <NSObject>

@optional
/**
 *  点击了选择按钮
 *
 *  @param cell self
 *  @param btn  按钮
 */
- (void)AddShortcutMenuTableViewCell:(AddShortcutMenuTableViewCell *)cell didPressBtn:(UIButton *)btn;

@end

@interface AddShortcutMenuTableViewCell : UITableViewCell

@property (nonatomic, weak)id <AddShortcutMenuTableViewCellDelegate> delegate;

//快捷方式图标
@property (strong, nonatomic) IBOutlet UIImageView *shortCutImageView;

//快捷方式名称
@property (strong, nonatomic) IBOutlet UILabel *shotCutNameLabel;

//选择按钮
@property (strong, nonatomic) IBOutlet UIButton *selectedBtn;

//是否被选中.
@property (nonatomic,assign) BOOL isSelected;

/**
 *  点击了选择按钮
 *
 *  @param sender
 */
- (IBAction)selectedBtnDidPress:(id)sender;

/**
 *  设置选中图片是否显示.
 *
 *  @param selected 是否选中该项
 */
-(void)isSelected:(BOOL)selected;
@end
