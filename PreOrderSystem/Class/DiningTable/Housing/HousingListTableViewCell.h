//
//  HousingListTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <UIKit/UIKit.h>

@class HousingListTableViewCell;

@protocol HousingListTableViewCellDelegate <NSObject>

- (void)deleteHousing:(HousingListTableViewCell *)cell;
- (void)housingNameChange:(HousingListTableViewCell *)cell withNewHousingName:(NSString *)name;

@end

@interface HousingListTableViewCell : UITableViewCell<UITextFieldDelegate>
{
    
}

@property (nonatomic, weak) id <HousingListTableViewCellDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UITextField *housingTextField;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (void)refreshCellAfterGetData:(NSString *)dict;

@end
