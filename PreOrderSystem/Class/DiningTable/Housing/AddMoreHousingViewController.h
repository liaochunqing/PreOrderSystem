//
//  AddMoreHousingViewController.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-23.
//
//

#import <UIKit/UIKit.h>
#import "AddMoreHousingTableViewCell.h"

@class AddMoreHousingViewController;
@protocol AddMoreHousingViewControllerDelegete <NSObject>

- (void)addMoreHousingViewController:(AddMoreHousingViewController *)ctrl withNewHousingData:(NSArray *)housingArray;

@end

@interface AddMoreHousingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AddMoreHousingTableViewCellDelegate, CustomTableViewCellDelegate>

@property(nonatomic, weak) id <AddMoreHousingViewControllerDelegete> delegate;
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
@property(nonatomic, weak) IBOutlet UIButton *finishButton;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *maxLenLabel;
@property(nonatomic, weak) IBOutlet UILabel *promptLabel;
@property(nonatomic, weak) IBOutlet UITableView *housingTableView;
@property(nonatomic, weak) IBOutlet UITextField *addHousingTextField;
@property(nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property(nonatomic, assign) int tag;

@end
