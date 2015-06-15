//
//  DishCardItemPriceTableviewCell.h
//  PreOrderSystem
//
//  Created by AaronKwok on 13-4-16.
//
//

#import <UIKit/UIKit.h>
#import "NumPicker.h"


#define kDishCardItemPriceTableviewCellReuseIdentifier @"dishCardItemPriceTableviewCellIdentifier"

@class DishCardItemPriceTableviewCell;
@protocol DishCardItemPriceTableviewCellDelegate <NSObject>

//通知添加新的菜品成功
- (void)dishCardItemPriceTableviewCell:(DishCardItemPriceTableviewCell *)cell withAddStyle:(NSString *)styleStr withAddPriceStr:(NSString *)priceStr;
- (void)dishCardItemPriceTableviewCell:(DishCardItemPriceTableviewCell *)cell withStyleChanged:(NSString *)styleStr;
- (void)dishCardItemPriceTableviewCell:(DishCardItemPriceTableviewCell *)cell withPriceStrChanged:(NSString *)priceStr;
//通知修改菜品成功
-(void)DishCardItemPriceTableviewCellDidDeletedItem:(DishCardItemPriceTableviewCell*)cell;
//通知开始编辑菜品的价格
-(void)DishCardItemPriceTableviewCellDidBeginEditingPrice:(DishCardItemPriceTableviewCell*)cell;

@end

@interface DishCardItemPriceTableviewCell : UITableViewCell<UITextFieldDelegate, NumPickerDelegate>
{
    id <DishCardItemPriceTableviewCellDelegate> __weak delegate;
    __weak UILabel *titleLabel;
    __weak UILabel *unitLabel;
    __weak UIButton *addItemButton;
    __weak UIButton *deleteItemButton;
    __weak UITextField *itemStyleTextfield;
    __weak UITextField *itemPriceTextfield;
    NumPicker *picker;
    id popoverController;
}
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UIButton *addItemButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteItemButton;
@property (weak, nonatomic) IBOutlet UITextField *itemStyleTextfield;
@property (weak, nonatomic) IBOutlet UITextField *itemPriceTextfield;
@property (assign, nonatomic) NSInteger tag;
@property (strong, nonatomic) id popoverController;

-(void)updateCellInfo:(NSDictionary*)info;

@end
