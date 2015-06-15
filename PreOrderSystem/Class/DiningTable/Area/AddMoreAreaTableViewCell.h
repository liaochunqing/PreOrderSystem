//
//  AddMoreAreaTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCellDelegate.h"

@class AddMoreAreaTableViewCell;

@protocol AddMoreAreaTableViewCellDelegate <NSObject>

- (void)deleteArea:(AddMoreAreaTableViewCell*)cell;
- (void)areaNameChange:(AddMoreAreaTableViewCell*)cell withNewAreaName:(NSString *)name;

@end

@interface AddMoreAreaTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id <AddMoreAreaTableViewCellDelegate, CustomTableViewCellDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UITextField *areaTextField;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (void)refreshCellAfterGetData:(NSString *)housingStr;

@end
