//
//  RemarkItemTableViewCell.h
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import <UIKit/UIKit.h>

#define kRemarkItemTableViewCellReuseIdentifier @"remarkItemTableViewCellIdentifier"

@class RemarkItemTableViewCell;

@protocol RemarkItemTableViewCellDelegate <NSObject>

- (void)deleteRemarkItem:(RemarkItemTableViewCell *)cell;
- (void)remarkItemChange:(RemarkItemTableViewCell *)cell withNewItem:(NSString *)itemStr;

@end

@interface RemarkItemTableViewCell : UITableViewCell<UITextFieldDelegate>


@property (nonatomic, weak) id <RemarkItemTableViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (void)updateViewAfterGetData:(NSString *)remarkNameStr;


@end
