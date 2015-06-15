//
//  DishCardRemarkViewController.h
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import <UIKit/UIKit.h>

#import "JsonPicker.h"
#import "RemarkItemTableViewCell.h"

@class RemarkCuisineTableViewCell;
@class DishCardRemarkViewController;

@protocol DishCardRemarkViewControllerDelegate <NSObject>

- (void)dismissViewOfRemarkViewController:(DishCardRemarkViewController *)ctrl;

@end

@interface DishCardRemarkViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, JsonPickerDelegate, RemarkItemTableViewCellDelegate>

@property (nonatomic, weak) id <DishCardRemarkViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *cuisineTableView;
@property (nonatomic, weak) IBOutlet UITableView *remarkTableView;
@property (nonatomic, weak) IBOutlet UITextField *addRemarkTextField;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *cuisineBgImageView;
@property (nonatomic, weak) IBOutlet UIButton *addRemarkButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

- (void)dismissView;

@end
