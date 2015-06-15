//
//  EditDiscountTableViewCell.h
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import <UIKit/UIKit.h>
#import "NumPicker.h"
#import "CookbookDataClass.h"
@class EditDiscountTableViewCell;
@protocol EditDiscountTableViewCellProtocol <NSObject>

@optional

/**
 *  开始编辑自定义价格
 *
 *  @param cell self
 */
- (void)EditDiscountTableViewCellDidBeginEditingPrice:(EditDiscountTableViewCell *)cell;

/**
 *  自定义价格输入框完成编辑
 *
 *  @param cell        self
 *  @param customPrice 自定义价格 (string *)
 */
- (void)EditDiscountTableViewCell:(EditDiscountTableViewCell *)cell didFinishEditingPrice:(NSString *)customPrice;

@end

@interface EditDiscountTableViewCell : UITableViewCell<UITextFieldDelegate,NumPickerDelegate>

@property (nonatomic, weak) id <EditDiscountTableViewCellProtocol> delegate;

//菜系名
@property (strong, nonatomic) IBOutlet UILabel *cuisineNameLabel;

//菜品名
@property (strong, nonatomic) IBOutlet UILabel *cookbookNameLabel;

//价格类型
@property (strong, nonatomic) IBOutlet UILabel *priceStyle;

//价格
@property (strong, nonatomic) IBOutlet UITextField *CustomPrice;

//删除按钮
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

//菜品数据模型
@property (strong, nonatomic) CookbookDataClass *cookBook;

//价格输入键盘.
@property (nonatomic,strong) NumPicker *picker;
@property (strong, nonatomic) id popoverController;


/**
 *  点击cell的删除按钮,删除本行.
 *
 *  @param sender btn
 */
- (IBAction)deleteBtnPress:(id)sender;

@end

