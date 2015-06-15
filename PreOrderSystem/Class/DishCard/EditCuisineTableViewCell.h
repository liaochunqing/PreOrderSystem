//
//  EditCuisineTableViewCell.h
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import <UIKit/UIKit.h>

#define kEditCuisineTableViewCellReuseIdentifier @"editCuisineTableViewCellIdentifier"

@class EditCuisineTableViewCell;
@protocol EditCuisineTableViewCellDelegate <NSObject>

- (void)deleteCuisine:(EditCuisineTableViewCell*)cell;
- (void)cuisineNameChange:(EditCuisineTableViewCell*)cell withNewCuisineName:(NSString *)name;
- (void)moveViewUpWhenKeyboardShow:(EditCuisineTableViewCell*)cell;
- (void)moveViewBackWhenKeyboardHide:(EditCuisineTableViewCell*)cell;

@end

@interface EditCuisineTableViewCell : UITableViewCell<UITextFieldDelegate>
{
    
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UITextField *cuisineTextField;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (void)refreshCellAfterGetData:(NSDictionary *)dict;
- (IBAction)deleteButtonPressed:(UIButton *)sender;

@end
