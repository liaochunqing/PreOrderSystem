//
//  AddMoreHousingTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCellDelegate.h"

@class AddMoreHousingTableViewCell;

@protocol AddMoreHousingTableViewCellDelegate <NSObject>

- (void)deleteHousing:(AddMoreHousingTableViewCell*)cell;
- (void)housingNameChange:(AddMoreHousingTableViewCell*)cell withNewHousingName:(NSString *)name;

@end

@interface AddMoreHousingTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id <AddMoreHousingTableViewCellDelegate, CustomTableViewCellDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UITextField *housingTextField;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (void)refreshCellAfterGetData:(NSString *)housingStr;

@end
