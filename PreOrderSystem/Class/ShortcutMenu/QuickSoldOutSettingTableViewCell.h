//
//  EditDiscountTableViewCell.h
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import <UIKit/UIKit.h>

@class QuickSoldOutSettingTableViewCell;
@protocol QuickSoldOutSettingTableViewCellProtocol <NSObject>

@optional
/**
 *  自定义价格输入框完成编辑
 *
 *  @param cell        self
 *  @param customPrice 自定义价格 (string *)
 */
- (void)QuickSoldOutSettingTableViewCell:(QuickSoldOutSettingTableViewCell *)cell soldOutSwitchChanged:(UISwitch *)soldOutSwitch;



@end

@interface QuickSoldOutSettingTableViewCell : UITableViewCell

@property (nonatomic, weak) id <QuickSoldOutSettingTableViewCellProtocol> delegate;

//菜系名
@property (strong, nonatomic) IBOutlet UILabel *cuisineNameLabel;

//菜品名
@property (strong, nonatomic) IBOutlet UILabel *cookbookNameLabel;

//删除按钮
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

//已沽清开关
@property (strong, nonatomic) IBOutlet UISwitch *soldOutSwitch;

- (IBAction)soldOutSwitchChanged:(UISwitch *)sender;

@end

