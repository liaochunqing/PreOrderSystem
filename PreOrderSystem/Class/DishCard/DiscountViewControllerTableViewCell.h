//
//  DiscountViewControllerTableViewCell.h
//  PreOrderSystem
//
//  Created by mac on 14-7-3.
//
//

#import <UIKit/UIKit.h>

@interface DiscountViewControllerTableViewCell : UITableViewCell
//优惠套餐ID
@property (strong, nonatomic) IBOutlet UILabel *discountID;

//优惠套餐名称
@property (strong, nonatomic) IBOutlet UILabel *discountName;

//删除套餐按钮
@property (strong, nonatomic) IBOutlet UIButton *deleteItemBtn;

//优惠套餐启用/停用开关
@property (strong, nonatomic) IBOutlet UISwitch *discountSwitch;

//菜品数量
@property (strong, nonatomic) IBOutlet UILabel *dishNumLabel;

@end
