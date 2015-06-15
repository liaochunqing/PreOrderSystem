//
//  AreaListTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <UIKit/UIKit.h>

@class AreaListTableViewCell;

@protocol AreaListTableViewCellDelegate <NSObject>

- (void)deleteArea:(AreaListTableViewCell*)cell;
- (void)gotoHousingListView:(AreaListTableViewCell*)cell;
- (void)areaNameChange:(AreaListTableViewCell*)cell withNewAreaName:(NSString *)name;

@end

@interface AreaListTableViewCell : UITableViewCell<UITextFieldDelegate>
{
    
}

@property (nonatomic, weak) id <AreaListTableViewCellDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UITextField *areaTextField;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *addHousingButton;

- (void)refreshCellAfterGetData:(NSString *)dict;

@end
