//
//  DishCardNewDetailTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-7-16.
//
//

#import <UIKit/UIKit.h>
#import "NumPicker.h"
#import "CookbookDataClass.h"

@class DishCardNewDetailTableViewCell;
typedef void (^hideKeyboardBlock)();

@protocol DishCardNewDetailTableViewCellDelegate <NSObject>

- (void)DishCardNewDetailTableViewCell:(DishCardNewDetailTableViewCell*)cell hideKeyboard:(BOOL)flag;
- (void)DishCardNewDetailTableViewCell:(DishCardNewDetailTableViewCell*)cell changeChooseNumber:(NSInteger)chooseNumber;
@end

@interface DishCardNewDetailTableViewCell : UITableViewCell <NumPickerDelegate, UITextFieldDelegate>
{
    NumPicker *_picker;
    id _popoverController;
}

@property (nonatomic,weak)id <DishCardNewDetailTableViewCellDelegate> delegate;
@property (copy, nonatomic) hideKeyboardBlock hideKBBlock;//隐藏键盘
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

-(void)updateCellInfo:(id) info;
@end
