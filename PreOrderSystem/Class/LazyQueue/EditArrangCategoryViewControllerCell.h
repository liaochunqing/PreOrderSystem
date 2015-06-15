//
//  EditArrangCategoryViewControllerCell.h
//  PreOrderSystem
//
//  Created by sWen on 13-3-8.
//
//

#import <UIKit/UIKit.h>

#define kEditArrangCategoryCellReuseIdentifier @"editArrangCategoryCellIdentifier"
#define kArrangCategoryCapacityLen 2

@class EditArrangCategoryViewControllerCell;

@protocol EditArrangCategoryViewControllerCellDelegate <NSObject>

- (void)deleteArrangCategory:(EditArrangCategoryViewControllerCell *)cell;
- (void)ArrangCategoryChange:(EditArrangCategoryViewControllerCell *)cell withNewCategory:(NSString *)category withNewMinCapacity:(int)minCapacity withNewMaxCapacity:(int)maxCapacity;
- (void)moveViewUpWhenKeyboardShow:(EditArrangCategoryViewControllerCell *)cell;
- (void)moveViewBackWhenKeyboardHide:(EditArrangCategoryViewControllerCell *)cell;

@end

@interface EditArrangCategoryViewControllerCell : UITableViewCell<UITextFieldDelegate>


@property (nonatomic, weak) id <EditArrangCategoryViewControllerCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITextField *categoryTextField;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UITextField *minCapacityField;
@property (nonatomic, weak) IBOutlet UITextField *maxCapacityField;
@property (nonatomic, weak) IBOutlet UILabel *personLabel;

- (void)updateEditArrangCategoryCell:(NSDictionary *)categoryDict;

@end
