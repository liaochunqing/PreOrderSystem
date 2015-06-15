//
//  AddMoreAreaViewController.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-23.
//
//

#import <UIKit/UIKit.h>
#import "AddMoreAreaTableViewCell.h"

@class AddMoreAreaViewController;
@protocol AddMoreAreaViewControllerDelegete <NSObject>

- (void)addMoreAreaViewController:(AddMoreAreaViewController *)ctrl withNewAreaData:(NSArray *)areaArray;

@end

@interface AddMoreAreaViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AddMoreAreaTableViewCellDelegate, CustomTableViewCellDelegate>

@property(nonatomic, weak) id <AddMoreAreaViewControllerDelegete> delegate;
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
@property(nonatomic, weak) IBOutlet UIButton *finishButton;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *maxLenLabel;
@property(nonatomic, weak) IBOutlet UILabel *promptLabel;
@property(nonatomic, weak) IBOutlet UITableView *areaTableView;
@property(nonatomic, weak) IBOutlet UITextField *addAreaTextField;
@property(nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property(nonatomic, assign) int tag;

@end
